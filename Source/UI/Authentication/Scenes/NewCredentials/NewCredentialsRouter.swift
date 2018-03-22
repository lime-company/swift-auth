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

public protocol NewCredentialsRoutingLogic {
    
    func routeToCancel()
    func routeToSuccess(password: String)
    func routeToError(error: LimeAuthError?)
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?)
}

/// Protocol for controller covering a whole "create password" operation
public protocol NewCredentialsRoutableController: AuthenticationUIProcessController {
    
    func connectCreatePasswordRouter(router: AuthenticationUIProcessRouter & NewCredentialsRoutingLogic)
}


public class NewCredentialsRouter: NewCredentialsRoutingLogic, AuthenticationUIProcessRouter {
    
    public var authenticationProcess: AuthenticationUIProcess!
    public var viewController: (UIViewController & NewCredentialsRoutableController)?
    
    public func connect(controller: AuthenticationUIProcessController) {
        viewController = controller as? (UIViewController & NewCredentialsRoutableController)
        assert(viewController != nil)
    }
    
    public func routeToCancel() {
        authenticationProcess.cancelAuthentication(controller: viewController)
    }
    
    public func routeToSuccess(password: String) {
        authenticationProcess.completeAuthentication(controller: viewController)
    }
    
    public func routeToError(error: LimeAuthError?) {
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
        if authenticationProcess.isPartOfActivation {
            if let activationVC = destinationVC as? ActivationUIProcessController {
                activationVC.connect(activationProcess: authenticationProcess.activationProcess)
            }
        }
    }
}
