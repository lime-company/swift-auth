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

/// Class that holds information about recovery data (activation code and PUK).
public class LimeAuthRecoveryData {
    
    /// Activation code as provided by powerauth protocol
    public let activationCode: String
    /// PUK as provided by powerauth protocol
    public let puk: String
    /// Activation ID of the original activation
    public let originalActivationId: String?
    /// Identifier of the application for the activation transfer
    public let appTransferId: String?
    
    /// Formatted activation code with dashes for displaying on the screen
    public var activationCodeFormatted: String {
        var code = activationCode
        if code.count == 20 {
            for c in 3...1 {
                code.insert("–", at: code.index(code.startIndex, offsetBy: c * 5))
            }
        }
        return code
    }
    
    /// Formatted PUK with one dash in the middle for displaying on the screen.
    public var pukFormatted: String {
        var code = puk
        if code.count == 10 {
            code.insert(contentsOf: "–", at: code.index(code.startIndex, offsetBy: 5))
        }
        return code
    }
    
    public var qrCodeData: String {
        return "\(activationCode)\n\(puk)\n\(originalActivationId ?? "")\n\(appTransferId ?? "")"
    }
    
    init(activationCode: String, puk: String, originalActivationId: String?, appTransferId: String?) {
        self.activationCode = activationCode
        self.puk = puk
        self.originalActivationId = originalActivationId
        self.appTransferId = appTransferId
    }
    
    convenience init?(scannerQrCode: String, appTransferId: String?) {
        
        let parts = scannerQrCode.split(separator: "\n").map(String.init)
        
        guard parts.count >= 2 else {
            return nil
        }
        
        let code = parts[0]
        guard PA2OtpUtil.validateRecoveryCode(code) else {
            return nil
        }
        
        let puk = parts[1]
        guard PA2OtpUtil.validateRecoveryPuk(puk) else {
            return nil
        }
        
        var activationId = parts.count >= 3 ? parts[2] : nil
        var scannedAppTransferId = parts.count >= 4 ? parts[3] : nil
        
        if activationId?.isEmpty == true {
            activationId = nil
        }
        
        if scannedAppTransferId?.isEmpty == true {
            scannedAppTransferId = nil
        }
        
        if let sati = scannedAppTransferId, sati != appTransferId {
            return nil
        }
        
        self.init(activationCode: code, puk: puk, originalActivationId: activationId, appTransferId: scannedAppTransferId)
    }
}

public extension LimeAuthSession {
    
    /// Returns if current activation has recovery data. Recovery data are encrypted and needs to be unlocked first with
    /// vault unlock. To get recovery data use `getActivationRecovery`.
    var hasRecoveryActivation: Bool {
        return powerAuth.hasActivationRecoveryData()
    }

    /// Unlocks the vault with provided authentication and retrieves the recovery data. This methdo does not check if the data exists in the first place - you
    /// should do it with `hasRecoveryActivation` check first.
    @discardableResult
    func getActivationRecovery(authentication: PowerAuthAuthentication, completion: @escaping (PA2ActivationRecoveryData?, LimeAuthError?)->Void) -> Operation {
        
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
                    
                    completion(recoveryData, nil)
                }
            }
        }
        return addOperationToQueue(blockOperation, serialized: true)
    }
}
