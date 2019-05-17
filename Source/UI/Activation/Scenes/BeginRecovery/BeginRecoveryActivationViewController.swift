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

open class BeginRecoveryActivationViewController: LimeAuthUIBaseViewController, ActivationUIProcessController {
    
    public var router: (ActivationUIProcessRouter & BeginRecoveryActivationRoutingLogic)!
    public var uiDataProvider: ActivationUIDataProvider!
    public var cameraAccessProvider: CameraAccessProvider!
    
    @IBOutlet weak var cancelButton: CancelWizardButton!
    @IBOutlet weak var illustration: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var continueButton: PrimaryWizardButton!
    
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
        let router = BeginRecoveryActivationRouter()
        router.viewController = self
        viewController.router = router
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    open override func configureController() {
        guard let _ = router?.activationProcess else {
            D.fatalError("BeginActivationViewController is not configured properly.")
        }
        // Change behavior of cancel operation
        router.activationProcess.cancelShouldRouteToBegin = true
    }
    
    open override func prepareUI() {
        
        super.prepareUI()
        
        let uiData = uiDataProvider.uiDataForBeginRecoveryActivation
        let commonStrings = uiDataProvider.uiCommonStrings
        let theme = uiDataProvider.uiTheme
        
        illustration?.setLazyImage(theme.illustrations.beginRecoveryScene)
        titleLabel?.text = uiData.strings.sceneTitle
        message?.text = uiData.strings.sceneDescription
        cancelButton?.setTitle(commonStrings.cancelTitle, for: .normal)
        continueButton?.setTitle(uiData.strings.continueButton, for: .normal)
        
        configureBackground(image: theme.common.backgroundImage, color: theme.common.backgroundColor)
        titleLabel?.textColor = theme.common.titleColor
        message?.textColor = theme.common.textColor
        cancelButton?.applyButtonStyle(theme.buttons.cancel)
        continueButton?.applyButtonStyle(theme.buttons.primary)
    }
    
    
    // MARK: - Routing
    
    open func connect(activationProcess process: ActivationUIProcess) {
        router?.activationProcess = process
        uiDataProvider = process.uiDataProvider
    }
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router?.prepare(for: segue, sender: sender)
    }
    
    // MARK: - UI Actions
    
    @IBAction func manualCodeAction(_ sender: UIButton) {
        router?.routeToEnterCode()
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        router?.cancelActivation()
    }
}
