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

import UIKit

protocol PassphraseVerifying {
    var passphraseValidator: LimeAuthPassphraseValidator? { get }
}

extension PassphraseVerifying where Self: UIViewController {
    
    /// Checks given passphrase if it's weak. If so, alert will be presented to the user to inform him about this issue and
    /// gives him option to continue or to choose different passphrase
    ///
    /// - Parameters:
    ///   - passphrase: passphrase that will be walidated
    ///   - type: type of the passphrase
    ///   - uiDataProvider: provider for localization access
    ///   - completion: called when validation is completed
    ///   - continue: continue or ask for new passphrase
    func verifyPassphrase(_ passphrase: String, type: LimeAuthPassphraseType, uiDataProvider: AuthenticationUIDataProvider, completion: @escaping (_ `continue`: Bool) -> Void) {
        
        let result: LimeAuthPassphraseResult?
        var different: String
        var ignore: String
        
        if type == .pin {
            result = passphraseValidator?.validate(passphrase, type: .pin)
            different = uiDataProvider.uiPassphraseStrengthStrings.pickDifferentPinButton
            ignore = uiDataProvider.uiPassphraseStrengthStrings.ignorePinButton
        } else {
            result = passphraseValidator?.validate(passphrase, type: .password)
            different = uiDataProvider.uiPassphraseStrengthStrings.pickDifferentPasswordButton
            ignore = uiDataProvider.uiPassphraseStrengthStrings.ignorePasswordButton
        }
        
        // make sure that result is warning
        guard let r = result, case .warning(let message) = r else {
            completion(true)
            return
        }
        
        let alert = UIAlertController(title: uiDataProvider.uiPassphraseStrengthStrings.warningTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: different, style: .destructive) { _ in
            completion(false)
        })
        
        alert.addAction(UIAlertAction(title: ignore, style: .cancel) { _ in
            completion(true)
        })
        
        present(alert, animated: true, completion: nil)
    }
}
