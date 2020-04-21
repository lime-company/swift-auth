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
import PowerAuth2

open class KeysExchangeViewController: LimeAuthUIBaseViewController, ActivationUIProcessController {
    
    public var router: (ActivationUIProcessRouter & KeysExchangeRoutingLogic)!
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
        let router = KeysExchangeRouter()
        router.viewController = self
        viewController.router = router
    }
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        createActivation()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        sessionOperation?.cancel()
    }
    
    open override func configureController() {
        guard let _ = router?.activationProcess,
            let _ = router?.activationProcess.activationData.activationCode else {
                D.fatalError("KeysExchangeViewController is not configured properly.")
        }
    }
    
    // MARK: - Routing
    
    open func connect(activationProcess process: ActivationUIProcess) {
        router?.activationProcess = process
        uiDataProvider = process.uiDataProvider
    }
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router?.prepare(for: segue, sender: sender)
    }
    
    
    // MARK: - Begin activation
    
    private weak var sessionOperation: Operation?
    
    public func createActivation() {
        
        let process = router.activationProcess!
        
        let activationName = UIDevice.current.name
        let activationCode = process.activationData.activationCode ?? ""
        
        let completion = { [weak self] (result: PA2ActivationResult?, error: LimeAuthError?) in
            guard let `self` = self else {
                return
            }
            self.sessionOperation = nil
            if let result = result {
                self.router.routeToCreatePassword(with: result)
            } else if let error = error {
                self.router.routeToError(with: error)
            }
        }
        
        if let puk = process.activationData.puk {
            sessionOperation = router.activationProcess.session.createActivation(name: activationName, extras: nil, recoveryCode: activationCode, puk: puk, completion: completion)
        } else {
            sessionOperation = router.activationProcess.session.createActivation(name: activationName, activationCode: activationCode, otp: process.activationData.activationOTP, completion: completion)
        }
    }
    
    
    // MARK: - Presentation
    
    @IBOutlet weak var pendingActivityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var pendingDescriptionLabel: UILabel?
    
    // MARK: -
    
    open override func prepareUI() {
        
        let uiData = uiDataProvider.uiDataForKeysExchange
        let theme = uiDataProvider.uiTheme
        
        // Apply image & texts
        pendingDescriptionLabel?.text = uiData.strings.pendingActivationTitle
        
        // Apply styles
        configureBackground(image: theme.common.backgroundImage, color: theme.common.backgroundColor)
        pendingDescriptionLabel?.textColor = theme.common.textColor
        pendingActivityIndicator?.applyIndicatorStyle(theme.common.activityIndicator)
    }
    
}
