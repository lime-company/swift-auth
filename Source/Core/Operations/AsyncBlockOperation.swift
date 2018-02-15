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

internal class AsyncBlockOperation<Result, Cancellable> : AsyncOperation<Result, Cancellable> {
    
    typealias OperationType = AsyncOperation<Result, Cancellable>
    
    typealias ExecuteBlock = (OperationType) -> Cancellable?
    typealias CompleteBlock = (OperationType, Result?, Error?) -> Void
    typealias CancelBlock = (OperationType, Cancellable) -> Void
    
    private var _execution: ExecuteBlock
    private var _completion: CompleteBlock
    private var _cancelation: CancelBlock?
    
    init(_ execute: @escaping ExecuteBlock, completion: @escaping CompleteBlock, cancel: CancelBlock? = nil) {
        
        _execution = execute
        _completion = completion
        _cancelation = cancel
    }

    final override func onExecute() -> Cancellable? {
        return _execution(self)
    }
    
    final override func onComplete(result: Result?, error: Error?) {
        _completion(self, result, error)
    }
    
    final override func onCancel(_ cancellable: Cancellable) {
        _cancelation?(self, cancellable)
    }

}
