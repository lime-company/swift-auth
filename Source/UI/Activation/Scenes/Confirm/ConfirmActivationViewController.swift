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

public class ConfirmActivationViewController: LimeAuthUIBaseViewController, ActivationProcessController {
    
    public var router: (ConfirmActivationRoutingLogic & ActivationProcessRouter)!
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
        let router = ConfirmActivationRouter()
        router.viewController = self
        viewController.router = router
    }
    
    // MARK: - View lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = router?.activationProcess,
			let _ = router?.activationProcess.activationData.password else {
            fatalError("ConfirmActivationViewController is not configured properly.")
        }
		let ad = router.activationProcess.activationData
		if ad.createActivationResult == nil && ad.noActivationResult == false {
			fatalError("ConfirmActivationViewController createActivationResult or noActivationResult is not configured.")
		}
		
        prepareUI()
		commitActivation()
    }
	
	public override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		stopWaiting()
	}
	
	
    // MARK: - Routing
    
    public func connect(activationProcess process: ActivationProcess) {
        router?.activationProcess = process
        uiDataProvider = process.uiDataProvider
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router?.prepare(for: segue, sender: sender)
    }
    
    
    // MARK: - Interactions
    
    @IBAction func removeActivationAction(_ sender: Any) {
        removeActivation()
    }
    
    public func removeActivation() {
		router.activationProcess.session.removeActivationLocal()
        router.routeToCancel()
    }
	
	
	// MARK: - Commit & Wait
	
	public func commitActivation() {
		
        // TODO: we need to store device's key fingerprint to the keychain and restore
        //       it in case of repairing a broken, unfinished activation.
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
			if let error = error {
				self?.router.routeToError(with: error)
			} else {
				self?.waitForActivationConfirmation()
			}
		}
	}
	
	private var waitingWorkItem: DispatchWorkItem?
    private var fetchOperation: Operation?
	private var statusAttempts: Int = 0
	
	private func waitForActivationConfirmation() {
        statusAttempts = statusAttempts + 1
        if statusAttempts == 5 {
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: t)
                self.waitingWorkItem = t
            }
        }
        
	}
    
    private func processStatus(_ status: PA2ActivationStatus?, error: Error?) -> Bool {
        if let status = status {
            switch status.state {
            case .active:
                router.routeToSuccess()
            case .removed:
                // make expiration error...
                router.routeToCancel()
            case .blocked:
                // make activation blocked error...
                router.routeToCancel()
            case .created:
                return true
            case .otp_Used:
                return true
            }
        } else if let error = error {
            if (error as NSError).domain != PA2ErrorDomain {
                return true
            } else {
                router.routeToError(with: error)
            }
        }
        return false
    }
	
	private func stopWaiting() {
		waitingWorkItem?.cancel()
		waitingWorkItem = nil
        fetchOperation?.cancel()
        fetchOperation = nil
	}
    
    
    // MARK: - Presentation
    
	@IBOutlet weak var sceneTitleLabel: UILabel?
	@IBOutlet weak var sceneDescriptionLabel: UILabel?
	@IBOutlet weak var promoImageView: UIImageView?
	@IBOutlet weak var waitingForActivationLabel: UILabel?
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView?
	@IBOutlet weak var removeActivationButton: UIButton?
    
    // MARK: -
    
    open func prepareUI() {
		let uiData = uiDataProvider.uiDataForConfirmActivation
		
        if uiData.images.confirm.hasImage {
            promoImageView?.image = uiData.images.confirm.image
        }
		sceneTitleLabel?.text = uiData.strings.sceneTitle
		sceneDescriptionLabel?.text = uiData.strings.sceneDescription
		waitingForActivationLabel?.text = uiData.strings.waitingLabel
		removeActivationButton?.setTitle(uiData.strings.removeActivationButton, for: .normal)
		// Hide remove button in initial state
		removeActivationButton?.alpha = 0
    }
}


