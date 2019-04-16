//
// Copyright 2019 Wultra s.r.o.
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

public class LimeAuthRecoveryData {
    
    public let activationCode: String
    public let puk: String
    
    public var activationCodeFormatted: String {
        var code = activationCode
        if code.count == 20 {
            for c in 3...1 {
                code.insert("-", at: code.index(code.startIndex, offsetBy: c * 5))
            }
        }
        return code.replacingOccurrences(of: "-", with: " - ")
    }
    
    public var pukFormatted: String {
        var code = puk
        if code.count == 10 {
            code.insert(contentsOf: " - ", at: code.index(code.startIndex, offsetBy: 5))
        }
        return code
    }
    
    init(activationCode: String, puk: String) {
        self.activationCode = activationCode
        self.puk = puk
    }
}

public extension LimeAuthSession {
    
    var hasRecoveryActivation: Bool {
        return powerAuth.hasActivationRecoveryData()
    }
    
    @discardableResult
    func getActivationRecovery(authentication: PowerAuthAuthentication, completion: @escaping (LimeAuthRecoveryData?, LimeAuthError?)->Void) -> Operation {
        
        let blockOperation = AsyncBlockOperation { operation, markFinished in
            self.powerAuth.activationRecoveryData(authentication) { recoveryData, error in
                
                markFinished {
                    
                    guard error == nil else {
                        completion(nil, LimeAuthError.wrap(error))
                        return
                    }
                    
                    guard let recoveryData = recoveryData else {
                        completion(nil, LimeAuthError(string: "No recovery data available"))
                        return
                    }
                    
                    completion(LimeAuthRecoveryData(activationCode: recoveryData.recoveryCode, puk: recoveryData.puk), nil)
                }
            }
        }
        return addOperationToQueue(blockOperation, serialized: true)
    }
}
