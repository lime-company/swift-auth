//
// Copyright 2018 Wultra s.r.o.
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

/** Async operation that takes block as main execution article.
 
 To properly use this class, you need to pass execution block and when the block finishes any
 asynchronous work, call `completion` block that is passed as 2nd parameter to this block.
*/
public class AsyncBlockOperation: AsyncOperation {
    
    /// Type of block that needs to be passed in init
    ///
    /// - Parameter this: Reference to this operation
    /// - Parameter markFinished: Call this completion block to mark operation as finished. You can pass closure
    ///   that will complete this operation to be sure things get called in proper order on proper queue.
    public typealias ExecutionBlock = (_ this: AsyncBlockOperation, _ markFinished: @escaping MarkFinishedBlock) -> Void
    public typealias MarkFinishedBlock = ((() -> Void)?) -> Void
    
    private let executionBlock: ExecutionBlock
    
    /// Create async operation with block, that does asynchronous work.
    ///
    /// - Parameter executionBlock: Closure that will be executed when the operation starts.
    ///   See its type documentation (`ExecutionBlock`) for more info.
    public init(_ executionBlock: @escaping ExecutionBlock) {
        self.executionBlock = executionBlock
        super.init()
    }
    
    final public override func started() {
        
        // first, execute block that was recieved in initializer
        executionBlock(self) { [weak self] completion in
            
            // when markFinished is called, mark operation finished
            self?.markFinished(completion: completion)
        }
    }
}
