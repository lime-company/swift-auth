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

open class EnableBiometryViewController: LimeAuthUIBaseViewController, ActivationUIProcessController {
    
    public var router: (EnableBiometryRoutingLogic & ActivationUIProcessRouter)!
    public var uiDataProvider: ActivationUIDataProvider!
    
    var isTouchId: Bool = PA2Keychain.supportedBiometricAuthentication == .touchID
    
    // MARK: - Object lifecycle
    
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
        let router = EnableBiometryRouter()
        router.viewController = self
        viewController.router = router
    }
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Routing
    
    open func connect(activationProcess process: ActivationUIProcess) {
        router?.activationProcess = process
        uiDataProvider = process.uiDataProvider
    }
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router?.prepare(for: segue, sender: sender)
    }
    
    open override func configureController() {
        guard let _ = router?.activationProcess else {
            fatalError("EnableBiometryViewController is not configured properly.")
        }
        guard PA2Keychain.supportedBiometricAuthentication != .none else {
            fatalError("EnableBiometryViewController biometry is not supported.")
        }
    }
    
    // MARK: - Interactions
    
    @IBAction func enableBiometryAction(_ sender: Any) {
        enableBiometry(enable: true)
    }
    
    @IBAction func enableLaterAction(_ sender: Any) {
        enableBiometry(enable: false)
    }
    
    public func enableBiometry(enable: Bool) {
        router?.routeToConfirm(withBiometryEnabled: enable)
    }
    
    
    
    // MARK: - Presentation
    
    @IBOutlet weak var sceneTitleLabel: UILabel?
    @IBOutlet weak var sceneDescriptionLabel: UILabel?
    @IBOutlet weak var promoImageView: UIImageView?
    @IBOutlet weak var enableBiometryButton: UIButton?
    @IBOutlet weak var enableLaterButton: UIButton?
    
    // MARK: -
    
    open override func prepareUI() {
        let uiData = uiDataProvider.uiDataForEnableBiometry
        let theme = uiDataProvider.uiTheme

        // Apply images & texts
        let isTouchId = PA2Keychain.supportedBiometricAuthentication == .touchID
        
        let sceneTitle          = isTouchId ? uiData.strings.touchIdSceneTitle : uiData.strings.faceIdSceneTitle
        let description         = isTouchId ? uiData.strings.touchIdDescription : uiData.strings.faceIdDescription
        let enableButtonTitle   = isTouchId ? uiData.strings.enableTouchIdButton : uiData.strings.enableFaceIdButton
        
        sceneTitleLabel?.text = sceneTitle
        sceneDescriptionLabel?.text = description
        enableBiometryButton?.setTitle(enableButtonTitle, for: .normal)
        enableLaterButton?.setTitle(uiData.strings.enableLaterButton, for: .normal)
        promoImageView?.setLazyImage(theme.illustrations.enableBiometryScene)
        
        // Apply styles
        configureBackground(image: theme.common.backgroundImage, color: theme.common.backgroundColor)
        sceneTitleLabel?.textColor = theme.common.titleColor
        sceneDescriptionLabel?.textColor = theme.common.textColor
        enableBiometryButton?.applyButtonStyle(theme.buttons.primary)
        enableLaterButton?.applyButtonStyle(theme.buttons.secondary)
    }
    
}


