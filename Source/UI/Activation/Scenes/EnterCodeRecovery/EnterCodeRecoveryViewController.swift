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

import UIKit
import PowerAuth2

open class EnterCodeRecoveryViewController: LimeAuthUIBaseViewController, ActivationUIProcessController, ActivationCodeDelegate, PukViewDelegate {
    
    @IBOutlet weak var codeView: ActivationCodeView!
    @IBOutlet weak var pukView: PukView!
    @IBOutlet weak var confirmButton: PrimaryWizardButton!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var pukLabel: UILabel!
    
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
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        codeView.delegate = self
        pukView.delegate = self
        confirmButton.isEnabled = false
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        //registerForKeyboardNotifications()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        //unregisterForKeyboardNotifications()
        self.view.resignFirstResponder()
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
    
    open override func prepareUI() {
        
        let theme = uiDataProvider.uiTheme
        
        configureBackground(image: nil, color: theme.common.backgroundColor)
        codeLabel.textColor = theme.common.textColor
        pukLabel.textColor = theme.common.textColor
        confirmButton?.applyButtonStyle(theme.buttons.primary)
        
        codeView.prepareComponent(uiDataProvider: uiDataProvider)
        pukView.prepareComponent(uiDataProvider: uiDataProvider)
    }
    
    @IBAction func continueAction(_ sender: UIButton) {
        let code = codeView.buildCode()
        let puk = pukView.buildPUK()
        router.routeToKeyExchange(activationCode: code, puk: puk)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        router.routeToCancel()
    }
    
    public func pukChanged(puk: String) {
        validateInfo()
    }
    
    public func codeChanged(code: String) {
        validateInfo()
    }
    
    private func validateInfo() {
        let code = codeView.buildCode()
        let puk = pukView.buildPUK()
        
        confirmButton.isEnabled = PA2OtpUtil.validateRecoveryCode(code) && PA2OtpUtil.validateRecoveryPuk(puk)
    }
}
