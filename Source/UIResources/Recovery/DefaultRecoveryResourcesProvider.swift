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
import LimeCore

class DefaultRecoveryResourcesProvider: RecoveryUIProvider, RecoveryUIDataProvider {
    
    private let bundle: Bundle
    private let localization: GenericLocalizationProvider
    private let theme: LimeAuthRecoveryUITheme
    
    init(bundle: Bundle? = nil, localizationProvider: GenericLocalizationProvider?, theme: LimeAuthRecoveryUITheme?) {
        self.bundle = bundle ?? .limeAuthResourcesBundle
        self.localization = localizationProvider ?? SystemLocalizationProvider(tableName: "LimeAuth", bundle: .limeAuthResourcesBundle)
        self.theme = theme ?? .defaultLightTheme
    }
    
    func instantiateRecoveryController() -> RecoveryViewController {
        guard let vc = UIStoryboard(name: "Recovery", bundle: bundle).instantiateInitialViewController() as? RecoveryViewController else {
            D.fatalError("RecoveryViewController not found")
        }
        return vc
    }
    
    var uiDataProvider: RecoveryUIDataProvider {
        return self
    }
    
    var uiTheme: LimeAuthRecoveryUITheme {
        return theme
    }
    
    lazy var activationStrings: RecoveryCode.UIData.Strings = {
        RecoveryCode.UIData.Strings(
            // TODO: LOCALIZE!
            sceneTitle: "Activation recovery",
            description: "Please write your Activation code and PUK down and store it in a secure place.",
            activationCodeHeader: "ACTIVATION CODE",
            pukHeader: "PUK",
            warning: "If you'll lose your Recovery information, you won't be able to re-activate again on a new device. In such case you will need to visit us on one of our branches.",
            continueButton: "Continue",
            continueButtonWithSeconds: "Continue (%@)",
            errorTitle: "Something went wrong",
            errorText: "Failed to get your recovery codes. These codes are important part of your activation and needed in situations where you'll need to activate a new device. You can display your recovery code anytime in Mobile Key settings.",
            retryButton: "Try again",
            skipButton: "Get recovery codes later"
        )
    }()
    
    lazy var reactivationStrings: RecoveryCode.UIData.Strings = {
        return activationStrings
    }()
    
    lazy var standaloneStrings: RecoveryCode.UIData.Strings = {
        return activationStrings
    }()
    
}
