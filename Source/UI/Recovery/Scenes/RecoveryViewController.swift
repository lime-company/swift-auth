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

public class RecoveryViewController: LimeAuthUIBaseViewController, RecoveryViewDelegate {
    
    public enum DisplayContext {
        case activation
        case reactivation
        case standalone
    }
    
    public typealias FinishedCallback = (_ displayed: Bool) -> Void
    
    var showCountdownDelay = true
    
    private var isRecoveryLoading = false
    private var uiProvider: RecoveryUIProvider!
    private var finishedCallback: FinishedCallback!
    private var displayContext: DisplayContext!
    private var recoveryData: LimeAuthRecoveryData!
    
    @IBOutlet private weak var displayView: RecoveryDisplayView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    
    public func setup(withData data: LimeAuthRecoveryData, uiProvider: RecoveryUIProvider, context: DisplayContext, finishedCallback: @escaping FinishedCallback) {
        guard self.uiProvider == nil else {
            D.warning("Controller was already setup")
            return
        }
        self.uiProvider = uiProvider
        self.finishedCallback = finishedCallback
        self.displayContext = context
        self.recoveryData = data
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if uiProvider.uiDataProvider.uiTheme.recoveryScene.warnUserAboutScreenshot {
            NotificationCenter.default.addObserver(self, selector: #selector(userDidTakeScreenshot), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override public func prepareUI() {
        super.prepareUI()
        let strings: RecoveryCode.UIData.Strings
        
        switch displayContext! {
        case .activation: strings = uiProvider.uiDataProvider.activationStrings
        case .reactivation: strings = uiProvider.uiDataProvider.reactivationStrings
        case .standalone: strings = uiProvider.uiDataProvider.standaloneStrings
        }
        
        let recoveryScene = uiProvider!.uiDataProvider.uiTheme.recoveryScene
        configureBackground(image: recoveryScene.backgroundImage, color: recoveryScene.backgroundColor)
        
        titleLabel.text = strings.sceneTitle
        titleLabel.textColor = recoveryScene.titleColor
        displayView.prepareUI(theme: uiProvider!.uiDataProvider.uiTheme, strings: strings)
        displayView.showRecoveryCode(recoveryData, withWaitingCountdown: showCountdownDelay)
    }
    
    @objc private func userDidTakeScreenshot() {
        let alert = UIAlertController(title: uiProvider.uiDataProvider.screenshotAlertStrings.title, message: uiProvider.uiDataProvider.screenshotAlertStrings.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: uiProvider.uiDataProvider.screenshotAlertStrings.button, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Views delegate (actions)
    
    func continueAction() {
        finishedCallback(true)
    }
}
