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
        // Camera access
        cameraAccessProvider = CameraAccess()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    open override func configureController() {
        guard let _ = router?.activationProcess else {
            D.fatalError("BeginActivationViewController is not configured properly.")
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
    
    // MARK: - UI Actions
    
    @IBAction func scanCodeAction(_ sender: UIButton) {
        scanActivationCode()
    }
    
    @IBAction func manualCodeAction(_ sender: UIButton) {
        router?.routeToEnterCode()
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        router?.cancelActivation()
    }
    
    public func scanActivationCode() {
        if cameraAccessProvider.needsCameraAccessApproval {
            cameraAccessProvider.requestCameraAccess { granted in
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
}