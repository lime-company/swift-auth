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

open class EnterCodeRecoveryViewController: LimeAuthUIBaseViewController, ActivationUIProcessController {
    
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var pukField: UITextField!
    
    public var router: (ActivationUIProcessRouter & EnterCodeRecoveryRoutingLogic)!
    public var uiDataProvider: ActivationUIDataProvider!
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let viewController = self
        let router = EnterCodeRecoveryRouter()
        router.viewController = self
        viewController.router = router
    }
    
    open func connect(activationProcess process: ActivationUIProcess) {
        router?.activationProcess = process
        uiDataProvider = process.uiDataProvider
    }
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router?.prepare(for: segue, sender: sender)
    }
    
    @IBAction func continueAction(_ sender: UIButton) {
        let code = codeField.text ?? ""
        let puk = pukField.text ?? ""
        
        router?.routeToNextScreen(recoveryCode: code, puk: puk)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        router.routeToPreviousScene()
    }
}