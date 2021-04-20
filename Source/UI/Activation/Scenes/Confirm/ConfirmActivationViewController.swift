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

open class ConfirmActivationViewController: LimeAuthUIBaseViewController, ActivationUIProcessController {
    
    public var router: (ConfirmActivationRoutingLogic & ActivationUIProcessRouter)!
    public var uiDataProvider: ActivationUIDataProvider!
    
    private var actionFeedback: LimeAuthActionFeedback? {
        return router.activationProcess.uiProvider.actionFeedback
    }
    
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
        let router = ConfirmActivationRouter()
        router.viewController = self
        viewController.router = router
    }
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        commitActivation()
        actionFeedback?.prepare()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopWaiting()
    }
    
    private var recoveryFromBrokenActivation = false
    
    open override func configureController() {
        guard let _ = router?.activationProcess else {
            D.fatalError("ConfirmActivationViewController is not configured properly.")
        }
        let ad = router.activationProcess.activationData
        recoveryFromBrokenActivation = ad.recoveryFromFailedActivation
        
        guard let _ = ad.createActivationResult?.activationFingerprint else {
            D.fatalError("ConfirmActivationViewController missing activation fingerprint.")
        }
        if false == ad.recoveryFromFailedActivation {
            // For regular activation, password is required
            guard let _ = ad.password else {
                D.fatalError("ConfirmActivationViewController missing password.")
            }
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
    
    
    // MARK: - Interactions
    
    @IBAction func removeActivationAction(_ sender: Any) {
        removeActivation()
    }
    
    public func removeActivation() {
        stopWaiting()
        router.activationProcess.session.removeActivationLocal()
        router.routeToCancel()
    }
    
    
    // MARK: - Commit & Wait
    
    public func commitActivation() {
		
        let session = router.activationProcess.session
        if session.hasValidActivation {
            waitForActivationConfirmation()
            return
        }
        
        let activationData = router.activationProcess.activationData
        let authentication = PowerAuthAuthentication()
        authentication.usePossession = true
        authentication.useBiometry = activationData.useBiometry
        authentication.usePassword = activationData.password!

        let _ = session.commitActivation(authentication: authentication) { [weak self] (error) in
            guard let `self` = self else { return }
            if let error = error {
                let message = self.uiDataProvider.uiDataForConfirmActivation.errors.passwordSetupFailure
                self.router.routeToError(with: .wrap(error, string: message))
            } else {
                self.waitForActivationConfirmation()
            }
        }
    }
    
    private var waitingWorkItem: DispatchWorkItem?
    private weak var fetchOperation: Operation?
    private var statusAttempts: Int = 0
    
    private func waitForActivationConfirmation() {
        statusAttempts = statusAttempts + 1
        if statusAttempts == router.activationProcess.uiDataProvider.uiDataForConfirmActivation.other.statusCheckCountBeforeCancelButton {
            UIView.animate(withDuration: 0.33) {
                self.removeActivationButton?.alpha = 1
            }
        }
        fetchOperation = router.activationProcess.session.fetchActivationStatus { (status, _, error) in
            if self.processStatus(status, error: error) {
                // Continue in waiting
                let t = DispatchWorkItem {
                    self.waitForActivationConfirmation()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: t)
                self.waitingWorkItem = t
            }
        }
        
    }
    
    private func processStatus(_ status: PA2ActivationStatus?, error: LimeAuthError?) -> Bool {
        var errorToReport: LimeAuthError?
        if let status = status {
            switch status.state {
            case .active:
                router.routeToSuccess()
                actionFeedback?.scene(.operationSuccess)
            case .removed:
                errorToReport = LimeAuthError(string: uiDataProvider.uiDataForConfirmActivation.errors.activationRemoved)
            case .blocked, .deadlock: // including deadlock here for simplicity. It's very unlikely that it will actually happen
                errorToReport = LimeAuthError(string: uiDataProvider.uiDataForConfirmActivation.errors.activationBlocked)
            case .created:
                return true
            case .pendingCommit:
                return true
            @unknown default:
                D.fatalError("unknown state")
            }
        } else if let error = error {
            if error.domain != PA2ErrorDomain {
                return true
            } else {
                errorToReport = .wrap(error, string: uiDataProvider.uiDataForConfirmActivation.errors.activation)
            }
        }
        if let errorToReport = errorToReport {
            router.routeToError(with: errorToReport)
        }
        return false
    }
    
    private func stopWaiting() {
        waitingWorkItem?.cancel()
        waitingWorkItem = nil
        fetchOperation?.cancel()
        fetchOperation = nil
    }
	
	private var activationFingerprint: String {
		return router.activationProcess?.activationData.createActivationResult?.activationFingerprint ?? ""
	}
    
    
    // MARK: - Presentation
    
    @IBOutlet weak var sceneTitleLabel: UILabel?
    @IBOutlet weak var sceneDescriptionLabel: UILabel?
    @IBOutlet weak var promoImageView: UIImageView?
	@IBOutlet weak var activationFingerprintLabel: UILabel?
	@IBOutlet weak var waitingForActivationLabel: UILabel?
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView?
    @IBOutlet weak var centerActivityIndicatorView: UIActivityIndicatorView?
    @IBOutlet weak var removeActivationButton: UIButton?
    @IBOutlet weak var topUI: UIView?
    @IBOutlet weak var bottomUI: UIView?
    
    // MARK: -
    
    open override func prepareUI() {
        let uiData = uiDataProvider.uiDataForConfirmActivation
        let theme = uiDataProvider.uiTheme
        
        switch router.activationProcess.additionalOTP {
        case .authentication:
            topUI?.isHidden = true
            bottomUI?.isHidden = true
        case .none:
            centerActivityIndicatorView?.isHidden = true
        }
        
        // Apply texts & images
        promoImageView?.setLazyImage(theme.illustrations.confirmScene)
        sceneTitleLabel?.text = uiData.strings.sceneTitle
        sceneDescriptionLabel?.text = uiData.strings.sceneDescription
        waitingForActivationLabel?.text = uiData.strings.waitingLabel
        activationFingerprintLabel?.text = uiData.other.showConfirmationNumber ? self.activationFingerprint : ""
        removeActivationButton?.setTitle(uiData.strings.removeActivationButton, for: .normal)
        // Hide remove button in initial state, or show it when it's recovery from crashed activation
        // When the status check count is set to max.value, hide it
        removeActivationButton?.alpha = recoveryFromBrokenActivation && uiData.other.statusCheckCountBeforeCancelButton != Int.max ? 1.0 : 0.0
        
        // Apply styles
        configureBackground(image: theme.common.backgroundImage, color: theme.common.backgroundColor)
        sceneTitleLabel?.textColor = theme.common.titleColor
        if let font = theme.common.titleFont {
            sceneTitleLabel?.font = font
        }
        sceneDescriptionLabel?.textColor = theme.common.textColor
        waitingForActivationLabel?.textColor = theme.common.textColor
        activationFingerprintLabel?.textColor = theme.common.highlightedTextColor
        removeActivationButton?.applyButtonStyle(theme.buttons.destructive)
        activityIndicatorView?.applyIndicatorStyle(theme.common.activityIndicator)
        centerActivityIndicatorView?.applyIndicatorStyle(theme.common.activityIndicator)
    }
}


