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

public protocol BeginActivationRoutingLogic {
    func cancelActivation()
    
    func routeToScanCode()
    func routeToEnterCode()
    func routeToNoCameraAccess()
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?)
}

public class BeginActivationRouter: BeginActivationRoutingLogic, ActivationProcessRouter {
    
    public weak var viewController: BeginActivationViewController?
    public var activationProcess: ActivationProcess!
    
    public func routeToScanCode() {
        viewController?.performSegue(withIdentifier: "ScanCode", sender: nil)
    }
    
    public func routeToEnterCode() {
        viewController?.performSegue(withIdentifier: "EnterCode", sender: nil)
    }
    
    public func routeToNoCameraAccess() {
        viewController?.performSegue(withIdentifier: "NoCameraAccess", sender: nil)
    }
    
    public func cancelActivation() {
        activationProcess?.cancelActivation(controller: viewController)
    }
    
    public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationVC = segue.destination
        if let navigationVC = destinationVC as? UINavigationController, let first = navigationVC.viewControllers.first {
            destinationVC = first
        }
        if let activationVC = destinationVC as? ActivationProcessController {
            activationVC.connect(activationProcess: activationProcess)
        }
    }
    
}
