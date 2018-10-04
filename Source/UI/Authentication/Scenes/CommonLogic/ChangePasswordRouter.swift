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

public class EnterOldPasswordRouter: EnterPasswordRoutingLogic, AuthenticationUIProcessRouter {

    public weak var viewController: (UIViewController & AuthenticationUIProcessController)?
    public var authenticationProcess: AuthenticationUIProcess!

    public func connect(controller: AuthenticationUIProcessController) {
        viewController = controller as? (UIViewController & AuthenticationUIProcessController)
        assert(viewController != nil)
    }
    
    public func routeToCancel() {
        authenticationProcess.cancelAuthentication(controller: viewController)
    }

    public func routeToSuccess() {
        viewController?.performSegue(withIdentifier: "ChangePassword", sender: nil)
    }

    public func routeToError() {
        authenticationProcess.failAuthentication(controller: viewController)
    }

    public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationVC = segue.destination
        if let navigationVC = destinationVC as? UINavigationController, let first = navigationVC.viewControllers.first {
            destinationVC = first
        }
        if let authenticationVC = destinationVC as? AuthenticationUIProcessController {
            authenticationVC.connect(authenticationProcess: authenticationProcess)
        }
    }
}
