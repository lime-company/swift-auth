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

public class FakePasswordViewController: UIViewController, ActivationProcessController {
    
    public var activationProcess: ActivationProcess?
    
    public func connect(activationProcess process: ActivationProcess) {
        self.activationProcess = process
    }
    
	@IBOutlet weak var fakePassword: UITextField?
	
	@IBAction func fakeOk(_ sender: Any) {
		let password = fakePassword?.text ?? "1234"
		
		activationProcess?.activationData.password = password
		
		goNext()
	}
	
	func goNext() {
		if PA2Keychain.canUseBiometricAuthentication {
			self.performSegue(withIdentifier: "EnableBiometry", sender: nil)
		} else {
			self.performSegue(withIdentifier: "Confirm", sender: nil)
		}
	}
	
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationVC = segue.destination
        if let navigationVC = destinationVC as? UINavigationController, let first = navigationVC.viewControllers.first {
            destinationVC = first
        }
        if let activationVC = destinationVC as? ActivationProcessController, let ap = activationProcess {
            activationVC.connect(activationProcess: ap)
        }
    }
    
}

