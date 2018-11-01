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
import LimeCore

internal class DefaultAuthenticationResourcesProvider: AuthenticationUIProvider, AuthenticationUIDataProvider {

    public let bundle: Bundle
    public let localization: GenericLocalizationProvider
    
    public init(bundle: Bundle? = nil, localizationProvider: GenericLocalizationProvider?) {
        self.bundle = bundle ?? .limeAuthResourcesBundle
        self.localization = localizationProvider ?? SystemLocalizationProvider(tableName: "LimeAuth", bundle: .limeAuthResourcesBundle)
    }
    
    private var storyboard: UIStoryboard {
        return UIStoryboard(name: "Authentication", bundle: bundle)
    }
    
    //
    
    func instantiateNewCredentialsScene() -> (UIViewController & NewCredentialsRoutableController) {
        guard let controller = storyboard.instantiateViewController(withIdentifier: "NewCredentials") as? (UIViewController & NewCredentialsRoutableController) else {
            fatalError("Cannot instantiate CreateNewPassword scene")
        }
        return controller
    }
    
    func instantiateEnterPasswordScene() -> (UIViewController & EnterPasswordRoutableController) {
        guard let controller = storyboard.instantiateViewController(withIdentifier: "EnterPassword") as? (UIViewController & EnterPasswordRoutableController) else {
            fatalError("Cannot instantiate EnterPassword scene")
        }
        return controller
    }
    
    func instantiateEnterPasscodeScene() -> (UIViewController & EnterPasswordRoutableController) {
        guard let controller = storyboard.instantiateViewController(withIdentifier: "EnterPasscode") as? (UIViewController & EnterPasswordRoutableController) else {
            fatalError("Cannot instantiate EnterPassword scene")
        }
        return controller
    }
    
    func instantiateEnterFixedPasscodeScene() -> (UIViewController & EnterPasswordRoutableController) {
        guard let controller = storyboard.instantiateViewController(withIdentifier: "EnterFixedPasscode") as? (UIViewController & EnterPasswordRoutableController) else {
            fatalError("Cannot instantiate EnterFixedPasscode scene")
        }
        return controller
    }
    
    func instantiateNavigationController(with rootController: UIViewController) -> UINavigationController? {
        return LimeAuthUINavigationController(rootViewController: rootController)
    }
    
    var uiDataProvider: AuthenticationUIDataProvider {
        return self
    }
    
    var uiTheme: LimeAuthAuthenticationUITheme = .fallbackTheme()
    lazy var uiCommonStrings: Authentication.UIData.CommonStrings = {
        Authentication.UIData.CommonStrings(
            enterPin: localization.localizedString("limeauth.auth.enterPin"),
            enterPassword: localization.localizedString("limeauth.auth.enterPassword"),
            useTouchId: localization.localizedString("limeauth.auth.useTouchId"),
            useFaceId: localization.localizedString("limeauth.auth.useFaceId"),
            okButton: localization.localizedString("limeauth.common.ok"),
            cancelButton: localization.localizedString("limeauth.common.cancel"),
            closeButton: localization.localizedString("limeauth.common.close"),
            yesButton: localization.localizedString("limeauth.common.yes"),
            noButton: localization.localizedString("limeauth.common.no"),
            pleaseWait: localization.localizedString("limeauth.auth.pleaseWait"),
            success: localization.localizedString("limeauth.auth.operationSuccess"),
            failure: localization.localizedString("limeauth.auth.operationFailure")
        )
    }()
    
    lazy var uiCommonErrors: Authentication.UIData.CommonErrors = {
        Authentication.UIData.CommonErrors(
            wrongPin: localization.localizedString("limeauth.err.wrongPin"),
            wrongPassword: localization.localizedString("limeauth.err.wrongPassword"),
            biometryNotRecognized_TouchId: localization.localizedString("limeauth.err.touchIdFail"),
            biometryNotRecognized_FaceId: localization.localizedString("limeauth.err.faceIdFail"),
            activationWasRemoved: localization.localizedString("limeauth.err.activationWasRemoved" ),
            activationIsBlocked: localization.localizedString("limeauth.err.activationIsBlocked")
        )
    }()
    
    lazy var uiOperationStrings: Authentication.UIData.OperationStrings = {
        Authentication.UIData.OperationStrings(
            changePassword_PromptPin: localization.localizedString("limeauth.auth.enterOldPin"),
            changePassword_PromptPassword: localization.localizedString("limeauth.auth.enterOldPassword"),
            changePassword_Activity: localization.localizedString("limeauth.op.changePass.activity"),
            
            removeDevice_Activity: localization.localizedString("limeauth.op.removeActivation.activity"),
            removeDevice_Success: localization.localizedString("limeauth.op.removeActivation.success"),
            removeDevice_TouchIdPrompt: localization.localizedString("limeauth.op.removeActivation.touchIdPrompt"),
            
            enableTouchId_Activity: localization.localizedString("limeauth.op.enableTouchId.activity"),
            enableTouchId_Success: localization.localizedString("limeauth.op.enableTouchId.success"),
            enableFaceId_Activity: localization.localizedString("limeauth.op.enableFaceId.activity"),
            enableFaceId_Success: localization.localizedString("limeauth.op.enableFaceId.success")
        )
    }()
    
    lazy var uiForCreateNewPassword: NewCredentials.UIData = {
        NewCredentials.UIData(
            strings: NewCredentials.UIData.Strings(
                enterNewPin: localization.localizedString("limeauth.auth.enterNewPin"),
                retypePin: localization.localizedString("limeauth.auth.retypeNewPin"),
                pinNoMatch: localization.localizedString("limeauth.auth.pinsNotMatch"),
                enterNewPassword: localization.localizedString("limeauth.auth.enterNewPassword"),
                retypePassword: localization.localizedString("limeauth.auth.retypeNewPassword"),
                passwordNoMatch: localization.localizedString("limeauth.auth.passwordsNotMatch"),
                changeComplexityTitle: localization.localizedString("limeauth.auth.changeComplexityTitle"),
                changeComplexityButton: localization.localizedString("limeauth.auth.changeComplexityButton")
            )
        )
    }()
    
    
    
    func localizePasswordComplexity(option: LimeAuthCredentials.Password) -> String {
        switch option.type {
        case .fixedPin:
            return localization.localizedFormattedString("limeauth.auth.fixedPin(n)", option.minimumLength)
        case .variablePin:
            return localization.localizedFormattedString("limeauth.auth.variablePin(min,max)", option.minimumLength, option.maximumLength)
        case .password:
            return localization.localizedFormattedString("limeauth.auth.password(min)", option.minimumLength)
        }
    }
    
    func localizeRemainingAttempts(attempts: UInt32) -> String {
        if attempts > 1 {
            return localization.localizedFormattedString("limeauth.auth.attempts.remaining(n)", attempts)
        } else if attempts == 1 {
            return localization.localizedString("limeauth.auth.attempts.last")
        } else {
            // We don't need to localized "no attempts left", because the activation is probably
            // already blocked and that label is no logner displayed.
            return ""
        }
    }
    
    func localizeError(error: LimeAuthError?, fallback: String?) -> String {
        if let error = error {
            if error.networkIsNotReachable {
                return localization.localizedString("limeauth.err.network.isOffline")
            }
            if error.networkConnectionIsNotTrusted {
                return localization.localizedString("limeauth.err.network.untrustedSSL")
            }
            let statusCode = error.httpStatusCode
            let statusCodeType = statusCode / 100
            if statusCodeType == 5 {
                // 5xx
                return localization.localizedString("limeauth.err.network.serverIsDown")
            }
        }
        return fallback ?? localization.localizedString("limeauth.err.generic")
    }
    
    func loadTheme(theme: LimeAuthAuthenticationUITheme) {
        uiTheme = theme
        LimeAuthUIBaseViewController.commonPreferredStatusBarStyle = theme.common.statusBarStyle
    }
}
