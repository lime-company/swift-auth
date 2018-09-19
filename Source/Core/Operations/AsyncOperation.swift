//
// Copyright 2018 Lime - HighTech Solutions s.r.o.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions
// and limitations under the License.
//

import Foundation

/// Base class for asynchronous operations that will be put in `OperationQueue`
public class AsyncOperation: Operation, CompletableInSpecificQueue {
    
    override public var isAsynchronous: Bool { return true }
    override public var isReady: Bool { return state == .isReady && dependencies.contains(where: { !$0.isFinished }) == false } // TODO: when migarted to swift 4.2, use dependencies.allSatisfy({ $0.isFinished })
    override public var isExecuting: Bool { return state == .isExecuting }
    override public var isFinished: Bool { return state.done }
    override public var isCancelled: Bool { return state == .isCanceled }
    
    // Internal state of the operation
    private var state: AsyncOperationState = .isReady {
        didSet {
            willChangeValue(forKey: oldValue.rawValue)
            willChangeValue(forKey: state.rawValue)
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: state.rawValue)
            if state == .isCanceled {
                canceled()
            }
        }
    }
    
    public internal(set) var completionQueue: DispatchQueue?
    
    // MARK: - Lifecycle of the operation
    
    public override init() {
        self.state = .isReady
        super.init()
    }
    
    /// Starts the operation. This method is called by OperationQueue. Do not call this method.
    final public override func start() {
        guard isCancelled == false else { return }
        state = .isExecuting
        started()
    }
    
    /// Advises the operation object that it should stop executing its task. This method does not force
    /// your operation code to stop. Instead, it updates the object’s internal flags to reflect the change in state.
    final public override func cancel() {
        state = .isCanceled
    }
    
    final public func markFinished(completion: (() -> Void)? = nil) {
        
        // create block, that will properly finish the operation
        let block = { [weak self] in
            completion?()
            self?.state = .isFinished
        }
        
        if let queue = completionQueue {
            // if completion queue is specified, do it in this queue
            queue.async {
                block()
            }
        } else {
            // else just execute the block
            block()
        }
    }
    
    // MARK: - Methods to override
    
    /// Implement your operation in this method. When the operation is finished, don't fotget to call `markFinished()`.
    /// If operation was crerated with `completionQueue`, use it to call completion.
    public func started() {
        fatalError("this method needs to be overriden")
    }
    
    /// Called when operation is canceled.
    public func canceled() {
        // to override
    }
    
    // MARK: - CompletableInSpecificQueue protocol
    
    public func assignCompletionDispatchQueue(_ queue: DispatchQueue?) {
        completionQueue = queue
    }
}

private enum AsyncOperationState: String {
    case isWaiting
    case isReady
    case isCanceled
    case isExecuting
    case isFinished
    
    var done: Bool {
        return self == .isCanceled || self == .isFinished
    }
}
