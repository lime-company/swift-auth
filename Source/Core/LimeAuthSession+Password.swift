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
import PowerAuth2

public extension LimeAuthSession {
    
    /// Function validates on server whether provided password is valid.
    public func validatePassword(password: String, completion: @escaping (LimeAuthError?)->Void) -> Operation {
        let operation = self.buildBlockOperation(execute: { (op) -> PA2OperationTask? in
            return self.powerAuth.validatePasswordCorrect(password) { (error) in
                op.finish(result: error == nil, error: .wrap(error))
            }
        }, completion: { (op, success: Bool?, error) in
            completion(error)
        }) { (op, cancellable) in
            cancellable.cancel()
        }
        return self.addOperationToQueue(operation, serialized: true)
    }
    
    /// Function changes user's password. The current password must be validated before you call this method,
    /// otherwise the user will no longer be able to authenticate with his knowledge factor.
    public func changeValidatedPassword(from: String, to: String, completion: @escaping (Bool)->Void) -> Operation {
        let blockOperation = BlockOperation {
            let result = self.powerAuth.unsafeChangePassword(from: from, to: to)
            self.operationCompletionQueue.async {
                completion(result)
            }
        }
        return self.addOperationToQueue(blockOperation, serialized: true)
    }
    
}
