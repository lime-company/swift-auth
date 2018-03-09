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

public protocol ErrorActivationRoutingLogic {
    func routeToEnd()
    func prepare(for segue: UIStoryboardSegue, sender: Any?)
}

public class ErrorActivationRouter: ErrorActivationRoutingLogic, ActivationProcessRouter {
    
    public var activationProcess: ActivationProcess!
    public weak var viewController: ErrorActivationViewController?
    

    public func routeToEnd() {
        if activationProcess.cancelShouldRouteToBegin, let initialVC = activationProcess.initialController {
            // UI flow has been invoked with begin controller, we can pop to that controller
            viewController?.navigationController?.popToViewController(initialVC, animated: true)
            activationProcess.clearActivationData()
        } else {
            // Otherwise report error immediately
            activationProcess.failActivation(controller: viewController, with: nil)
        }
    }
    
    public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // empty
    }
}
