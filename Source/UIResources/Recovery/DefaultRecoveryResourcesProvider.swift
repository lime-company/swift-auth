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
    
    lazy var activationStrings = RecoveryCode.UIData.Strings(
        sceneTitle: localization.localizedString("limeauth.recovery.act.title"),
        description: localization.localizedString("limeauth.recovery.act.description"),
        activationCodeHeader: localization.localizedString("limeauth.recovery.act.codeheader"),
        pukHeader: localization.localizedString("limeauth.recovery.act.pukHeader"),
        warning: localization.localizedString("limeauth.recovery.act.warning"),
        continueButton: localization.localizedString("limeauth.recovery.act.continue"),
        continueButtonWithSeconds: localization.localizedString("limeauth.recovery.act.continueSeconds")
    )
    
    lazy var reactivationStrings = RecoveryCode.UIData.Strings(
        sceneTitle: localization.localizedString("limeauth.recovery.react.title"),
        description: localization.localizedString("limeauth.recovery.react.description"),
        activationCodeHeader: localization.localizedString("limeauth.recovery.react.codeheader"),
        pukHeader: localization.localizedString("limeauth.recovery.react.pukHeader"),
        warning: localization.localizedString("limeauth.recovery.react.warning"),
        continueButton: localization.localizedString("limeauth.recovery.react.continue"),
        continueButtonWithSeconds: localization.localizedString("limeauth.recovery.react.continueSeconds")
    )
    
    lazy var standaloneStrings = RecoveryCode.UIData.Strings(
        sceneTitle: localization.localizedString("limeauth.recovery.view.title"),
        description: localization.localizedString("limeauth.recovery.view.description"),
        activationCodeHeader: localization.localizedString("limeauth.recovery.view.codeheader"),
        pukHeader: localization.localizedString("limeauth.recovery.view.pukHeader"),
        warning: localization.localizedString("limeauth.recovery.view.warning"),
        continueButton: localization.localizedString("limeauth.recovery.view.continue"),
        continueButtonWithSeconds: localization.localizedString("limeauth.recovery.view.continueSeconds")
    )
    
    lazy var screenshotAlertStrings = RecoveryCode.UIData.ScreenshotStrings(
        title: localization.localizedString("limeauth.recovery.screenshot.title"),
        message: localization.localizedString("limeauth.recovery.screenshot.message"),
        button: localization.localizedString("limeauth.recovery.screenshot.button")
    )
    
}
