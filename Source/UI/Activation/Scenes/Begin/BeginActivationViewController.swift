//
// Copyright 2018 Wultra s.r.o.
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

open class BeginActivationViewController: LimeAuthUIBaseViewController, ActivationUIProcessController {
    
    public var router: (ActivationUIProcessRouter & BeginActivationRoutingLogic)!
    public var uiDataProvider: ActivationUIDataProvider!
    public var cameraAccessProvider: CameraAccessProvider!
    
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
        let router = BeginActivationRouter()
        router.viewController = self
        viewController.router = router
        // Camera access
        cameraAccessProvider = CameraAccess()
        
    }
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    open override func configureController() {
        guard let _ = router?.activationProcess else {
            fatalError("BeginActivationViewController is not configured properly.")
        }
        // Change behavior of cancel operation
        router.activationProcess.cancelShouldRouteToBegin = true
    }
    
    // MARK: - Routing
    
    open func connect(activationProcess process: ActivationUIProcess) {
        router?.activationProcess = process
        uiDataProvider = process.uiDataProvider
    }
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router?.prepare(for: segue, sender: sender)
    }
    
    
    // MARK: - Interactions
    
    @IBAction func enterActivationCodeAction(_ sender: Any) {
        enterActivationCode()
    }
    
    @IBAction func scanActivationCodeAction(_ sender: Any) {
        scanActivationCode()
    }

    @IBAction func cancelActivationAction(_ sender: Any) {
        cancelActivation()
    }
    
    public func scanActivationCode() {
        if cameraAccessProvider.needsCameraAccessApproval {
            cameraAccessProvider.requestCameraAccess { (granted) in
                if granted {
                    self.router?.routeToScanCode()
                } else {
                    self.router?.routeToNoCameraAccess()
                }
            }
        } else if cameraAccessProvider.isCameraAccessGranted {
            self.router?.routeToScanCode()
        } else {
            self.router?.routeToNoCameraAccess()
        }
    }
    
    public func enterActivationCode() {
        router?.routeToEnterCode()
    }
    
    public func cancelActivation() {
        router?.cancelActivation()
    }
    
    // MARK: - Presentation
    
    @IBOutlet weak var sceneTitleLabel: UILabel?
    @IBOutlet weak var sceneDescriptionLabel: UILabel?
    @IBOutlet weak var promoImageView: UIImageView?
    @IBOutlet weak var scanAccessCodeButton: UIButton?
    @IBOutlet weak var enterAccessCodeButton: UIButton?
    @IBOutlet weak var cancelActivationButton: UIButton?
    
    // MARK: -
    
    open override func prepareUI() {
        
        let uiData = uiDataProvider.uiDataForBeginActivation
        let commonStrings = uiDataProvider.uiCommonStrings
        let theme = uiDataProvider.uiTheme
        
        // Apply texts & icons
        promoImageView?.setLazyImage(theme.illustrations.beginScene)
        sceneTitleLabel?.text = uiData.strings.sceneTitle
        sceneDescriptionLabel?.text = uiData.strings.sceneDescription
        enterAccessCodeButton?.setTitle(uiData.strings.enterButton, for: .normal)
        scanAccessCodeButton?.setTitle(uiData.strings.scanButton, for: .normal)
        cancelActivationButton?.setTitle(commonStrings.cancelTitle, for: .normal)
        
        scanAccessCodeButton?.isHidden = !cameraAccessProvider.isCameraDeviceAvailable
        
        // Apply styles
        configureBackground(image: theme.common.backgroundImage, color: theme.common.backgroundColor)
        sceneTitleLabel?.textColor = theme.common.titleColor
        sceneDescriptionLabel?.textColor = theme.common.textColor
        scanAccessCodeButton?.applyButtonStyle(theme.buttons.primary)
        enterAccessCodeButton?.applyButtonStyle(theme.buttons.secondary)
        cancelActivationButton?.applyButtonStyle(theme.buttons.cancel)
    }
}
