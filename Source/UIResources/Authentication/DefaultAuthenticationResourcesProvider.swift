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

internal class DefaultAuthenticationResourcesProvider: AuthenticationUIProvider, AuthenticationUIDataProvider {

    public let bundle: Bundle
    
    public init(bundle: Bundle? = nil) {
        self.bundle = bundle ?? .limeAuthResourcesBundle
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
    var uiCommonStrings: Authentication.UIData.CommonStrings = .fallbackStrings()
    var uiCommonErrors: Authentication.UIData.CommonErrors = .fallbackErrors()
    
    
    var uiForCreateNewPassword: NewCredentials.UIData {
        return .fallbackData()
    }
    
    func localizePasswordComplexity(option: LimeAuthCredentials.Password) -> String {
        switch option.type {
        case .fixedPin:
            return "\(option.minimumLength) digits long PIN"
        case .variablePin:
            return "\(option.minimumLength) to \(option.maximumLength) digits long PIN"
        case .password:
            return "Min. \(option.minimumLength) characters long password"
        }
    }
    
    func localizeRemainingAttempts(attempts: UInt32) -> String {
        if attempts > 1 {
            return "\(attempts) remaining attempts"
        } else if attempts == 1 {
            return "Last attempt"
        } else {
            return "No attempts left"
        }
    }
    
    func loadTheme(theme: LimeAuthAuthenticationUITheme) {
        uiTheme = theme
        LimeAuthUIBaseViewController.commonPreferredStatusBarStyle = theme.common.statusBarStyle
    }
}
