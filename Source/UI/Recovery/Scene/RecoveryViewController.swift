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

public class RecoveryViewController: LimeAuthUIBaseViewController, RecoveryViewDelegate, RecoveryPresenter {
    
    public typealias FinishedCallback = (_ displayed: Bool) -> Void
    
    private var isRecoveryLoading = false
    private var uiProvider: RecoveryUIProvider!
    private var viewModel: RecoveryViewModel!
    private var finishedCallback: FinishedCallback!
    private var insideActivtion: Bool!
    
    @IBOutlet private weak var displayView: RecoveryDisplayView!
    @IBOutlet private weak var errorView: RecoveryErrorView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    
    public func setup(withData data: LimeAuthRecoveryData, uiProvider: RecoveryUIProvider, insideActivtion: Bool, finishedCallback: @escaping FinishedCallback) {
        guard self.viewModel == nil else {
            D.warning("Controller was already setup")
            return
        }
        self.viewModel = RecoveryViewModel(withData: data)
        self.viewModel.presenter = self
        self.uiProvider = uiProvider
        self.finishedCallback = finishedCallback
        self.insideActivtion = insideActivtion
    }
    
    public func setup(withAuthentication auth: PowerAuthAuthentication, andSession session: LimeAuthSession, uiProvider: RecoveryUIProvider, insideActivtion: Bool, finishedCallback: @escaping FinishedCallback) {
        guard self.viewModel == nil else {
            D.warning("Controller was already setup")
            return
        }
        self.viewModel = RecoveryViewModel(withAuthentication: auth, andSession: session)
        self.viewModel.presenter = self
        self.uiProvider = uiProvider
        self.finishedCallback = finishedCallback
        self.insideActivtion = insideActivtion
    }
    
    override public func prepareUI() {
        super.prepareUI()
        hideAll()
        let strings = insideActivtion ? uiProvider.uiDataProvider.activationStrings : uiProvider.uiDataProvider.standaloneStrings
        titleLabel.text = strings.sceneTitle
        titleLabel.textColor = uiProvider.uiDataProvider.uiTheme.recoveryScene.titleColor
        displayView.prepareUI(theme: uiProvider!.uiDataProvider.uiTheme, strings: strings)
        errorView.prepareUI(theme: uiProvider!.uiDataProvider.uiTheme, strings: strings)
        viewModel.start()
    }
    
    // MARK: - UI display logic
    
    private func showLoading() {
        hideAll()
        loadingIndicator.startAnimating()
        loadingIndicator.isHidden = false
    }
    
    private func showCodes(code: LimeAuthRecoveryData) {
        hideAll()
        displayView.showRecoveryCode(code, withWaitingCountdown: insideActivtion)
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
    
    // MARK: Views delegate (actions)
    
    func continueAction() {
        finishedCallback(true)
    }
    
    func laterAction() {
        finishedCallback(false)
    }
    
    func tryAgainAction() {
        viewModel.getRecoveryCode()
    }
    
    // MARK: presenter delegate
    
    func presentState(_ state: RecoveryViewModel.DisplayState) {
        switch state {
        case .data(let data):
            showCodes(code: data)
        case .error:
            showError()
        case .loading:
            showLoading()
        }
    }
}
