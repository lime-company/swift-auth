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

import UIKit
import LimeCore

public extension LiemeAuthRecoveryUI {
    
    static func defaultResourcesProvider(bundle: Bundle? = nil, localizationProvider: GenericLocalizationProvider?, theme: LimeAuthRecoveryUITheme?) -> RecoveryUIProvider {
        return DefaultRecoveryResourcesProvider(bundle: bundle, localizationProvider: localizationProvider, theme: theme)
    }
}

public extension LimeAuthRecoveryUITheme {
    
    static var defaultDarkTheme: LimeAuthRecoveryUITheme {
        
        let activation = LimeAuthActivationUITheme.defaultDarkTheme()
        
        return LimeAuthRecoveryUITheme(recoveryScene: RecoveryCodeScene(
            titleColor: activation.common.titleColor,
            textColor: activation.common.textColor,
            warningTextColor: .red,
            headerTextColor: .gray,
            activationCodeColor: .orange,
            pukColor: .orange,
            errorTitleColor: .red,
            continueButtonStyle: activation.buttons.primary,
            skipButton: activation.buttons.secondary,
            errorButton: activation.buttons.destructive
        ))
    }
    
    static var defaultLightTheme: LimeAuthRecoveryUITheme {
        
        let activation = LimeAuthActivationUITheme.defaultLightTheme()
        
        return LimeAuthRecoveryUITheme(recoveryScene: RecoveryCodeScene(
            titleColor: activation.common.titleColor,
            textColor: activation.common.textColor,
            warningTextColor: .red,
            headerTextColor: .gray,
            activationCodeColor: .orange,
            pukColor: .orange,
            errorTitleColor: .red,
            continueButtonStyle: activation.buttons.primary,
            skipButton: activation.buttons.secondary,
            errorButton: activation.buttons.destructive
        ))
    }
}
