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

public protocol RecoveryCodeRoutingLogic {
    func routeToSuccess()
    func prepare(for segue: UIStoryboardSegue, sender: Any?)
}

class RecoveryCodeRouter: RecoveryCodeRoutingLogic, ActivationUIProcessRouter {
    
    public var activationProcess: ActivationUIProcess!
    weak var viewController: RecoveryCodeViewController?
    
    func routeToSuccess() {
        activationProcess.completeActivation(controller: viewController)
    }
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationVC = segue.destination
        if let navigationVC = destinationVC as? UINavigationController, let first = navigationVC.viewControllers.first {
            destinationVC = first
        }
        if let activationVC = destinationVC as? ActivationUIProcessController {
            activationVC.connect(activationProcess: activationProcess)
        }
    }
}
