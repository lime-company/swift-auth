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

public class RecoveryCodeViewController: LimeAuthUIBaseViewController, ActivationUIProcessController, RecoveryCodeViewDelegate {
    
    private var router: (RecoveryCodeRoutingLogic & ActivationUIProcessRouter)!
    private var uiDataProvider: ActivationUIDataProvider!
    
    private var isRecoveryLoading = false
    
    @IBOutlet private weak var displayView: RecoveryCodeDisplayView!
    @IBOutlet private weak var errorView: RecoveryCodeErrorView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        hideAll()
        getRecoveryCode()
    }
    
    private func setup() {
        let router = RecoveryCodeRouter()
        router.viewController = self
        self.router = router
    }
    
    public override func prepareUI() {
        super.prepareUI()
        titleLabel.text = uiDataProvider.uiDataForRecoveryCode.strings.sceneTitle
        titleLabel.textColor = uiDataProvider.uiTheme.common.titleColor
        displayView.prepareUI(provider: uiDataProvider)
        errorView.prepareUI(provider: uiDataProvider)
    }
    
    // MARK: - Recovery code loading
    
    private func getRecoveryCode() {
        
        guard isRecoveryLoading == false else {
            return
        }
        
        isRecoveryLoading = true
        showLoading()
        
        let auth = PowerAuthAuthentication.possession(withPassword: router.activationProcess.activationData.password ?? "")
        router.activationProcess.session.getActivationRecovery(authentication: auth) { [weak self] data, error in
            DispatchQueue.main.async {
                if let data = data {
                    self?.showCodes(code: data)
                } else {
                    self?.showError()
                }
                self?.isRecoveryLoading = false
            }
        }
    }
    
    // MARK: - UI display logic
    
    private func showLoading() {
        hideAll()
        loadingIndicator.startAnimating()
        loadingIndicator.isHidden = false
    }
    
    private func showCodes(code: LimeAuthRecoveryData) {
        hideAll()
        displayView.showRecoveryCode(code)
    }
    
    private func showError() {
        hideAll()
        displayView.hide()
        errorView.show()
    }
    
    private func hideAll() {
        displayView.hide()
        errorView.hide()
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
    }
    
    // MARK: - Routing
    
    open func connect(activationProcess process: ActivationUIProcess) {
        router?.activationProcess = process
        uiDataProvider = process.uiDataProvider
    }
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router?.prepare(for: segue, sender: sender)
    }
    
    // MARK: Views delegate (actions)
    
    func continueAction() {
        router?.routeToSuccess()
    }
    
    func laterAction() {
        router?.routeToSuccess()
    }
    
    func tryAgainAction() {
        getRecoveryCode()
    }
}
