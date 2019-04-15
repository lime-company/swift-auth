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

public protocol EnterCodeRecoveryRoutingLogic {
    
    func routeToPreviousScene()
    func routeToNextScreen(recoveryCode: String, puk: String)
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?)
}

public class EnterCodeRecoveryRouter: EnterCodeRecoveryRoutingLogic, ActivationUIProcessRouter {
    
    public weak var viewController: EnterCodeRecoveryViewController?
    public var activationProcess: ActivationUIProcess!
    
    public func routeToPreviousScene() {
        if activationProcess.cancelShouldRouteToBegin {
            // BeginScene is at the top of the stack
            viewController?.navigationController?.popViewController(animated: true)
        } else {
            activationProcess.cancelActivation(controller: viewController)
        }
    }
    
    public func routeToNextScreen(recoveryCode: String, puk: String) {
        // TODO!
        viewController?.performSegue(withIdentifier: "KeyExchange", sender: nil)
    }
    
    public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationVC = segue.destination
        if let navigationVC = destinationVC as? UINavigationController, let first = navigationVC.viewControllers.first {
            destinationVC = first
        }
        if let activationVC = destinationVC as? ActivationUIProcessController {
            activationVC.connect(activationProcess: activationProcess)
        }
    }
    
}
