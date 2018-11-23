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
import AVKit

open class ScanActivationCodeViewController: LimeAuthUIBaseViewController, ActivationUIProcessController, QRCodeProviderDelegate {
    
    public var router: (ActivationUIProcessRouter & ScanActivationCodeRoutingLogic)!
    public var uiDataProvider: ActivationUIDataProvider!
    public var qrCodeProvider: QRCodeProvider?
    
    
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
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        LimeAuthActionFeedback.shared.prepare()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        startScanner()
        animateInitialUI(animated: animated)
        startFallbackTimer()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanner()
        cancelFallbackTimer()
    }
    
    internal static var preferredStatusBarStyleForScanner: UIStatusBarStyle = .lightContent
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return ScanActivationCodeViewController.preferredStatusBarStyleForScanner
    }
    
    open override func configureController() {
        guard let _ = router?.activationProcess, let _ = qrCodeProvider else {
            fatalError("ScanActivationCodeViewController is not configured properly.")
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
    
    
    // MARK: - Scanner
    
    
    public func startScanner() {
        qrCodeProvider?.startScanner()
    }
    
    public func stopScanner() {
        qrCodeProvider?.stopScanner()
    }
    
    // MARK: - QRCodeProviderDelegate
    
    open func qrCodeProvider(_ provider: QRCodeProvider, didFinishWithError error: Error) {
        router.activationProcess.failActivation(controller: self, with: LimeAuthError.wrap(error))
        stopScanner()
    }
    
    open func qrCodeProvider(_ provider: QRCodeProvider, didFinishWithCode code: String) {
        router.routeToKeyExchange(activationCode: code)
        stopScanner()
    }
    
    open func qrCodeProvider(_ provider: QRCodeProvider, needsValidateCode code: String) -> Bool {
        guard let otp = PA2OtpUtil.parse(fromActivationCode: code) else {
            return false
        }
        if otp.activationSignature == nil {
            // signature is required for QR code
            return false
        }
        LimeAuthActionFeedback.shared.haptic(.impact(.medium))
        return true
    }
    
    open func qrCodeProviderCameraPreview(_ provider: QRCodeProvider, forSession session: AVCaptureSession?) -> UIView? {
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
    
    @IBOutlet weak var topViewConstraint: NSLayoutConstraint?
    @IBOutlet weak var sceneTitleLabel: UILabel?
    @IBOutlet weak var enterCodeFallbackButton: UIButton?
    @IBOutlet weak var closeSceneButton: UIButton?
    @IBOutlet weak var crossHairImageView: UIImageView?
    
    
    open override func prepareUI() {
        let uiData = uiDataProvider.uiDataForScanActivationCode
        let theme = uiDataProvider.uiTheme
        
        sceneTitleLabel?.text = uiData.strings.sceneTitle
        enterCodeFallbackButton?.setTitle(uiData.strings.enterCodeFallbackButton, for: .normal)
        enterCodeFallbackButton?.isHidden = true
        
        // Assign optional images
        sceneTitleLabel?.textColor = theme.scannerScene.titleColor
        crossHairImageView?.setLazyImage(theme.images.scannerCrosshair)
        enterCodeFallbackButton?.applyButtonStyle(theme.scannerScene.fallbackButton)
        closeSceneButton?.applyButtonStyle(theme.scannerScene.closeButton)
    }
    
    private func animateInitialUI(animated: Bool) {
        // Initial state
        sceneTitleLabel?.alpha = 0.0
        crossHairImageView?.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
        crossHairImageView?.alpha = 0.0
        closeSceneButton?.transform = CGAffineTransform.init(translationX: 0, y: 120)
        enterCodeFallbackButton?.isHidden = true
        
        // Animation
        let animationsBlock1 = {
            self.sceneTitleLabel?.alpha = 0.8
            self.crossHairImageView?.transform = CGAffineTransform.identity
            self.crossHairImageView?.alpha = 0.8
        }
        let animationsBlock2 = {
            self.closeSceneButton?.transform = CGAffineTransform.identity
        }
        if animated {
            UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.66, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                animationsBlock1()
            }) { (finished) in
                if finished {
                    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.66, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                        animationsBlock2()
                    })
                }
            }
        } else {
            animationsBlock1()
            animationsBlock2()
        }
    }
    
    // MARK: - Fallback timer
    
    var task: DispatchWorkItem? = nil
    
    private func startFallbackTimer() {
        guard task == nil else {
            return
        }
        let t = DispatchWorkItem { [weak self] in
            guard let this = self, this.task?.isCancelled == false else { return }
            UIView.animate(withDuration: 0.33) {
                this.enterCodeFallbackButton?.isHidden = false
            }
        }
        task = t
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: t)
    }
    
    private func cancelFallbackTimer() {
        task?.cancel()
        task = nil
    }
}
