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
    
    public var hasBiometryFactor: Bool {
        return powerAuth.hasBiometryFactor()
    }
    
    /// Adds biometry factor to the session. The user has to provide a password to unlock sensitive information,
    /// required for the operation.
    public func addBiometryFactor(password: String, completion: @escaping (LimeAuthError?)->Void) -> Operation {
        let operation = self.buildBlockOperation(execute: { (op) -> PA2OperationTask? in
            return self.powerAuth.addBiometryFactor(password) { (error) in
                op.finish(result: error == nil, error: .wrap(error))
            }
        }, completion: { (op, success: Bool?, error) in
            completion(error)
        }) { (op, cancellable) in
            cancellable.cancel()
        }
        return self.addOperationToQueue(operation, serialized: true)
    }
    
    /// Removes biometry factor from the session. The operation is asynchronous, but you can count with fact,
    /// that it's execution time is very short.
    public func removeBiometryFactor(completion: @escaping (Bool)->Void) -> Operation {
        let blockOperation = BlockOperation {
            let result = self.powerAuth.removeBiometryFactor()
            self.operationCompletionQueue.async {
                completion(result)
            }
        }
        return self.addOperationToQueue(blockOperation, serialized: true)
    }
    
    
    /// Returns true if authentication with using biometry is supported on this device.
    /// The implementation simply returns result from `PA2Keychain.canUseBiometricAuthentication`
    public static var canUseBiometricAuthentication: Bool {
        return PA2Keychain.canUseBiometricAuthentication
    }

    /// Returns true if authentication with using biometry is supported on this device.
    /// The implementation simply returns result from `PA2Keychain.supportedBiometricAuthentication`
    public static var supportedBiometricAuthentication: PA2BiometricAuthenticationType {
        return PA2Keychain.supportedBiometricAuthentication
    }
    
    /// Returns full information about biometry type and its state on this device.
    /// The implementation simply returns result from `PA2Keychain.biometricAuthenticationInfo`
    public static var biometricAuthenticationInfo: PA2BiometricAuthenticationInfo {
        return PA2Keychain.biometricAuthenticationInfo
    }
    
}
