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

open class ErrorActivationViewController: LimeAuthUIBaseViewController, ActivationUIProcessController {
    
    public var router: (ErrorActivationRoutingLogic & ActivationUIProcessRouter)!
    public var uiDataProvider: ActivationUIDataProvider!
    
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
        let router = ErrorActivationRouter()
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
            fatalError("ErrorActivationViewController is not configured properly.")
        }
    }
    
    // MARK: - Interactions

    @IBAction func closeErrorAction(_ sender: Any) {
        closeError()
    }
    
    public func closeError() {
        router.routeToEnd()
    }
    
    
    // MARK: - Presentation
    
    @IBOutlet weak var sceneTitleLabel: UILabel?
    @IBOutlet weak var sceneDescriptionLabel: UILabel?
    @IBOutlet weak var promoImageView: UIImageView?
    @IBOutlet weak var closeSceneButton: UIButton?
	
    // MARK: -
    
    open override func prepareUI() {
        let uiData = uiDataProvider.uiDataForErrorActivation
        let commonStrings = uiDataProvider.uiCommonStrings
        let theme = uiDataProvider.uiTheme
        
        // Apply texts & images
        promoImageView?.setLazyImage(uiData.images.errorIllustration)
        sceneTitleLabel?.text = uiData.strings.sceneTitle
        sceneDescriptionLabel?.text = uiData.strings.genericError
        closeSceneButton?.setTitle(commonStrings.closeTitle, for: .normal)
        // Apply styles
        configureBackground(image: theme.common.backgroundImage, color: theme.common.backgroundColor)
        sceneTitleLabel?.textColor = theme.common.titleColor
        sceneDescriptionLabel?.textColor = theme.common.textColor
        closeSceneButton?.applyButtonStyle(theme.buttons.primary)
    }
    
}

