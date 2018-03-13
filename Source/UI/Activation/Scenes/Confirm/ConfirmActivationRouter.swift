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

public protocol ConfirmActivationRoutingLogic {
    func routeToSuccess()
    func routeToError(with error: LimeAuthError)
    func routeToCancel()
    func prepare(for segue: UIStoryboardSegue, sender: Any?)
}

public class ConfirmActivationRouter: ConfirmActivationRoutingLogic, ActivationUIProcessRouter {
    
    public var activationProcess: ActivationUIProcess!
    public weak var viewController: ConfirmActivationViewController?
    

    public func routeToSuccess() {
        activationProcess.completeActivation(controller: viewController)
    }
    
    public func routeToError(with error: LimeAuthError) {
        activationProcess.storeFailureReason(error: error)
        self.viewController?.performSegue(withIdentifier: "ErrorActivation", sender: nil)
    }

    public func routeToCancel() {
        if activationProcess.cancelShouldRouteToBegin, let initialVC = activationProcess.initialController {
            activationProcess.clearActivationData()
            viewController?.navigationController?.popToViewController(initialVC, animated: true)
        } else {
            activationProcess.cancelActivation(controller: viewController)
        }
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


