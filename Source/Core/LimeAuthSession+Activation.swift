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
import PowerAuth2

public extension LimeAuthSession {
    
    static let didRemoveActivation = Notification.Name(rawValue: "LimeAuthSession_didRemoveActivation")
    
    // MARK: - Activation creation -
    
    /// Creates a new activation with given name and activation code by calling a PowerAuth Standard RESTful API endpoint '/pa/activation/create'.
    ///
    /// This is 1st step of the activation. If this operation succeeds, then you can call `commitActivation`
    func createActivation(name: String?, activationCode: String, completion: @escaping (PA2ActivationResult?, LimeAuthError?)->Void) -> Operation {
        
        let operation = AsyncBlockOperation { _, markFinished in
            self.powerAuth.createActivation(withName: name, activationCode: activationCode) { result, error in
                markFinished {
                    completion(result, .wrap(error))
                }
            }
        }
        return addOperationToQueue(operation, serialized: true)
    }
    
    /// Commits activation that was created and store session data using provided authentication instance.
    ///
    /// This is 2nd step of the activation. You can call this method only when `createActivation` previously succeeded.
    /// Note that the operation is asynchronous, but is typically executed very quicky. The `LimeAuthSession` is using
    /// its queue only for internal serialization purposes, so you don't need to show activity in the UI.
    func commitActivation(authentication: PowerAuthAuthentication, completion: @escaping (LimeAuthError?)->Void) -> Operation {
        
        let blockOperation = BlockOperation {
            var reportError: Error? = nil
            do {
                let _ = try self.powerAuth.commitActivation(with: authentication)
            } catch let error {
                reportError = error
            }
            self.operationCompletionQueue.async {
                completion(.wrap(reportError))
            }
        }
        return self.addOperationToQueue(blockOperation, serialized: true)
    }
    
    
    // MARK: - Activation Remove -
    
    /// Removes existing activation from the device.
    ///
    /// This method removes the activation session state and biometry factor key. Cached possession related
    /// key remains intact. Unlike the `removeActivation(authentication:completion:)`, this method doesn't inform
    // server about the removal. In this case user has to remove the activation by using another channel (typically
    // internet banking, or similar web management console)
    func removeActivationLocal() {
        powerAuth.removeActivationLocal()
        statusFetcher.clearLastFetchedData()
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: LimeAuthSession.didRemoveActivation, object: nil)
        }
    }
    
    
    /// Removes activation from the server. The method duplicates the same operation from PowerAuthSDK, but guarantees
    /// the synchronized execution with another calls to PA server.
    func removeActivation(authentication: PowerAuthAuthentication, completion: @escaping (LimeAuthError?)->Void) -> Operation {
        
        let operation = AsyncBlockOperation { _, markFinished in
            
            self.powerAuth.removeActivation(with: authentication) { error in
                if error == nil {
                    self.removeActivationLocal()
                }
                markFinished {
                    completion(.wrap(error))
                }
            }
        }
        return addOperationToQueue(operation, serialized: true)
    }
}
