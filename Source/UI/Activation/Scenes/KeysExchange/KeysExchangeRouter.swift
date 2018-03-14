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
import PowerAuth2

public protocol KeysExchangeRoutingLogic {

    func routeToCreatePassword(with result: PA2ActivationResult)
    func routeToError(with error: LimeAuthError)
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?)
}

public class KeysExchangeRouter: KeysExchangeRoutingLogic, ActivationUIProcessRouter {
    
    public weak var viewController: KeysExchangeViewController?
    public var activationProcess: ActivationUIProcess!
    
    private var authenticationUI: LimeAuthAuthenticationUI?
    
    public func routeToCreatePassword(with result: PA2ActivationResult) {
        // Keep activation result
        activationProcess.activationData.createActivationResult = result
        // Present create password UI
        let authUI = LimeAuthAuthenticationUI.uiForCreatePassword(activationProcess: activationProcess, uiProvider: activationProcess.uiProvider.authenticationUIProvider) { (result, error, _) in
            self.authenticationUI = nil
            if result == .success {
                self.routeToNextScene()
            } else if result == .failure {
                self.routeToError(with: error!)
            } else {
                // Otherwise cancel the operation
                self.activationProcess.cancelActivation(controller: self.viewController?.navigationController?.viewControllers.last)
            }
        }
        authenticationUI = authUI
        
        // Present AuthUI to activation flow
        if let navigationVC = viewController?.navigationController {
            authUI.pushEntryScene(to: navigationVC, animated: true)
        }
    }
    
    public func routeToNextScene() {
        let credentials = activationProcess.credentialsProvider.credentials
        if credentials.biometry.isSupportedOnDevice {
            viewController?.performSegue(withIdentifier: "EnableBiometry", sender: nil)
        } else {
            viewController?.performSegue(withIdentifier: "Confirm", sender: nil)
        }
    }
    
    public func routeToError(with error: LimeAuthError) {
        activationProcess.storeFailureReason(error: error)
        viewController?.performSegue(withIdentifier: "ErrorActivation", sender: nil)
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

