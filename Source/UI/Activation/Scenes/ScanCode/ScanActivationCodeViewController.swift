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
import AVKit

public class ScanActivationCodeViewController: UIViewController, ActivationProcessController, QRCodeProviderDelegate {
    
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
        let router = ScanActivationCodeRouter()
        router.viewController = self
        viewController.router = router
        // QRCodeProvider
        qrCodeProvider = QRCodeScanner()
        qrCodeProvider?.delegate = self
    }
    
    // MARK: - View lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = router?.activationProcess, let _ = qrCodeProvider else {
            fatalError("ScanActivationCodeViewController is not configured properly.")
        }
        
        prepareUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanner()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopScanner()
    }
    
    // MARK: - Routing
    
    public var router: (ActivationProcessRouter & ScanActivationCodeRoutingLogic)!
    
    public func connect(activationProcess process: ActivationProcess) {
        router?.activationProcess = process
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router?.prepare(for: segue, sender: sender)
    }
    
    
    // MARK: - Scanner
    
    public var qrCodeProvider: QRCodeProvider?
    
    public func startScanner() {
        qrCodeProvider?.startScanner()
    }
    
    public func stopScanner() {
        qrCodeProvider?.stopScanner()
    }
    
    // MARK: - QRCodeProviderDelegate
    
    public func qrCodeProvider(_ provider: QRCodeProvider, didFinishWithError error: Error) {
        D.print("ScanActivationCodeViewController: Scanner failed on error: \(error.localizedDescription)")
        router.activationProcess.completeActivation(controller: self, with: error)
    }
    
    public func qrCodeProvider(_ provider: QRCodeProvider, didFinishWithCode code: String) {
        router.routeToKeyExchange(activationCode: code)
    }
    
    public func qrCodeProvider(_ provider: QRCodeProvider, needsValidateCode code: String) -> Bool {
        guard let otp = PA2OtpUtil.parse(fromActivationCode: code) else {
            return false
        }
        if otp.activationSignature == nil {
            // signature is required for QR code
            return false
        }
        return true
    }
    
    public func qrCodeProviderCameraPreview(_ provider: QRCodeProvider, forSession session: AVCaptureSession?) -> UIView? {
        return self.view
    }
    
    
    // MARK: - Interactions
    
    @IBAction func closeSceneAction(_ sender: Any) {
        closeScene()
    }
    
    @IBAction func enterCodeFallbackAction(_ sender: Any) {
        enterCodeFallback()
    }
    
    public func closeScene() {
        router?.routeToPreviousScene()
    }
    
    public func enterCodeFallback() {
        router.routeToEnterCode()
    }
    
    
    
    // MARK: - Presentation
    
    @IBOutlet weak var sceneTitleLabel: UILabel?
    @IBOutlet weak var enterCodeFallbackButton: UIButton?
    @IBOutlet weak var closeSceneButton: UIButton?
    
    
    open func prepareUI() {
        let uiData = router.activationProcess.uiDataForScanActivationCode
        
        sceneTitleLabel?.text = uiData.strings.sceneTitle
        enterCodeFallbackButton?.setTitle(uiData.strings.enterCodeFallbackButton, for: .normal)
    }
    
    // TODO: show fallback button...
}
