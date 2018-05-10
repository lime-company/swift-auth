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

import UIKit

internal class DefaultActivationResourcesProvider: ActivationUIProvider, ActivationUIDataProvider {
    
    public var bundle: Bundle {
        return providedBundle ?? .limeAuthResourcesBundle
    }
    
    private var providedBundle: Bundle?
    
    public init(bundle: Bundle? = nil) {
        self.providedBundle = bundle
    }
    
    
    // MARK: - LimeAuthActivationUIProvider
    
    public func instantiateInitialScene() -> BeginActivationViewController {
        guard let controller = storyboard.instantiateInitialViewController() as? BeginActivationViewController else {
            fatalError("Cannot instantiate Initial scene")
        }
        return controller
    }
    
    public func instantiateConfirmScene() -> ConfirmActivationViewController {
        guard let controller = storyboard.instantiateViewController(withIdentifier: "Confirm") as? ConfirmActivationViewController else {
            fatalError("Cannot instantiate Confirm scene")
        }
        return controller
    }
    
    public func instantiateScanCodeScene() -> ScanActivationCodeViewController {
        guard let controller = storyboard.instantiateViewController(withIdentifier: "ScanCode") as? ScanActivationCodeViewController else {
            fatalError("Cannot instantiate ScanCode scene")
        }
        return controller
    }
    
    public func instantiateEnterCodeScene() -> EnterActivationCodeViewController {
        guard let controller = storyboard.instantiateViewController(withIdentifier: "EnterCode") as? EnterActivationCodeViewController else {
            fatalError("Cannot instantiate EnterCode scene")
        }
        return controller
    }
    
    public func instantiateNavigationController(with rootController: UIViewController) -> UINavigationController? {
        return UINavigationController(rootViewController: rootController)
    }
    
    public var uiDataProvider: ActivationUIDataProvider {
        return self
    }
    
    public lazy var authenticationUIProvider: AuthenticationUIProvider = {
        return DefaultAuthenticationResourcesProvider(bundle: bundle)
    }()
    
    
    //
    
    private var storyboard: UIStoryboard {
        return UIStoryboard(name: "Activation", bundle: bundle)
    }
    
    // MARK: - LimeAuthActivationUIDataProvider
    
    public var uiCommonStrings: Activation.UIData.CommonStrings = .fallbackStrings()
    public var uiCommonStyle: Activation.UIData.CommonStyle = .fallbackStyle()
    public var uiDataForBeginActivation: BeginActivation.UIData = .fallbackData()
    public var uiDataForNoCameraAccess: NoCameraAccess.UIData = .fallbackData()
    public var uiDataForEnterActivationCode: EnterActivationCode.UIData = .fallbackData()
    public var uiDataForScanActivationCode: ScanActivationCode.UIData = .fallbackData()
    public var uiDataForKeysExchange: KeysExchange.UIData = .fallbackData()
    public var uiDataForEnableBiometry: EnableBiometry.UIData = .fallbackData()
    public var uiDataForConfirmActivation: ConfirmActivation.UIData = .fallbackData()
    public var uiDataForErrorActivation: ErrorActivation.UIData = .fallbackData()

    public func loadTheme(theme: LimeAuthActivationUI.Theme) {
        // Create common style
        uiCommonStyle = Activation.UIData.CommonStyle(
            backgroundColor: theme.common.backgroundColor,
            backgroundImage: theme.common.backgroundImage,
            wizardTitleColor: theme.common.titleColor,
            wizardTextColor: theme.common.textColor,
            wizardAltTextColor: theme.common.highlightedTextColor,
            buttonWizardPrimary: theme.buttons.primary,
            buttonWizardSecondary: theme.buttons.secondary,
            buttonWizardCancel: theme.buttons.cancel,
            buttonWizardDestructive: theme.buttons.destructive,
            activityIndicator: theme.common.activityIndicator,
            keyboardAppearance: theme.common.keyboardAppearance
        )
        
        // Apply illustrations
        uiDataForBeginActivation.images.scenePromo = theme.illustrations.beginScene
        uiDataForNoCameraAccess.images.noAccess = theme.illustrations.noCameraScene
        uiDataForEnableBiometry.images.biometry = theme.illustrations.enableBiometryScene
        uiDataForConfirmActivation.images.confirm = theme.illustrations.confirmScene
        uiDataForErrorActivation.images.errorIllustration = theme.illustrations.errorScene
        // Scanner
        uiDataForScanActivationCode.images.crossHair = theme.images.scannerCrosshair
        uiDataForScanActivationCode.style = ScanActivationCode.UIData.Style(
            statusBarStyle: theme.scannerScene.statusBarStyle,
            promptColor: theme.scannerScene.titleColor,
            fallbackButton: theme.scannerScene.fallbackButton,
            closeButton: theme.scannerScene.closeButton)        
    }
}

