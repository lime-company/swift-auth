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

internal class AsyncOperation<Result, Cancellable>: Operation, CompletableInSpecificQueue {
    
    private var completionQueue: DispatchQueue?
    private var cancellable: Cancellable?
    private var resultReported = false
    
    final func assignCompletionDispatchQueue(_ queue: DispatchQueue?) {
        self.completionQueue = queue
    }
    
    // MARK: - Finish & cancel
    
    final func finish(error: LimeAuthError) {
        reportFinish(result: nil, error: error)
    }
    
    final func finish(result: Result) {
        reportFinish(result: result, error: nil)
    }
    
    final func finish(result: Result?, error: LimeAuthError?) {
        reportFinish(result: result, error: error)
    }
    
    final override func cancel() {
        super.cancel()
        _safeCompletionQueue.async {
            if let objectToCancel = self.cancellable {
                self.cancellable = nil
                self.onCancel(objectToCancel)
            }
        }
    }
    
    // MARK: - Methods for override
    
    func onComplete(result: Result?, error: LimeAuthError?) {
        // empty, you need to override this function
    }
    
    func onExecute() -> Cancellable? {
        // empty, you need to override this function
        return nil
    }
    
    func onCancel(_ cancellable: Cancellable) {
        // empty, override to implement cancel method
    }
    
    
    // MARK: - Getting operation state
    
    final override var isExecuting: Bool {
        return _executing
    }
    
    final override var isFinished: Bool {
        return _finished
    }
    
    final override var isAsynchronous: Bool {
        return true
    }
    
    
    // MARK: - Private execution & finish
    
    final override func main() {
        _executing = true
        cancellable = onExecute()
    }
    

    
    private func reportFinish(result: Result?, error: LimeAuthError?) {
        _executing = false
        _finished = true
        _safeCompletionQueue.async {
            if !self.isCancelled && !self.resultReported {
                self.resultReported = true
                self.onComplete(result: result, error: error)
            }
        }
    }
    
    private var _safeCompletionQueue: DispatchQueue {
        return completionQueue ?? .main
    }
    
    private var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    private var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
}
