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

import Foundation
import AVFoundation

public enum QRCodeProviderError: Error {
    case permissionDenied
    case notSupported
    case unknown
}

public protocol QRCodeProviderDelegate: class {
    /// Reports when scanner failed to start scanning. When called, scanner is stopped.
    func qrCodeProvider(_ provider: QRCodeProvider, didFinishWithError error: Error)
    /// Called everytime when valid QR code is found. When called, scanner is stopped
    func qrCodeProvider(_ provider: QRCodeProvider, didFinishWithCode code: String)
    /// Returns if given code is valid
    func qrCodeProvider(_ provider: QRCodeProvider, needsValidateCode code: String) -> Bool
    func qrCodeProviderCameraPreview(_ provider: QRCodeProvider, forSession session: AVCaptureSession?) -> UIView?
}

public protocol QRCodeProvider: CameraAccessProvider {
        
    var delegate: QRCodeProviderDelegate? { get set }
 
    var isScannerRunning: Bool { get }
    
    func startScanner()
    func stopScanner()
}


public class QRCodeScanner: NSObject, QRCodeProvider, AVCaptureMetadataOutputObjectsDelegate {
    
    public private(set) var captureSession: AVCaptureSession?
    private let captureSessionQueue = DispatchQueue(label: "LimeAuth.QRCodeScanner.CaptureSessionQueue")

    public private(set) weak var previewLayer: AVCaptureVideoPreviewLayer?
    private weak var previewView: UIView?
    
    // MARK: - QRCodeProvider protocol
    
    public weak var delegate: QRCodeProviderDelegate?
    
    public var isScannerRunning: Bool {
        return captureSession?.isRunning ?? false
    }
    
    /// Starts the scanner asynchronously.
    /// **Call ithis method on main thread.**
    public func startScanner() {
        prepareSession()
        guard let session = captureSession else { return }
        captureSessionQueue.async { [weak self] in
            if session.isRunning == false {
                DispatchQueue.main.async { // changing on main thread to prevent race condition
                    self?.reported = false
                }
                session.startRunning()
            }
        }
    }
    
    /// Stops the scanner asynchronously.
    /// **Call ithis method on main thread.**
    public func stopScanner() {
        previewView?.removeObserver(self, forKeyPath: "frame")
        guard let session = captureSession else {
            return
        }
        captureSessionQueue.async {
            if session.isRunning {
                session.stopRunning()
            }
        }
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate protocol
    
    @objc public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for item in metadataObjects {
            if let mrCodeItem = item as? AVMetadataMachineReadableCodeObject {
                if mrCodeItem.type == .qr, let code = mrCodeItem.stringValue {
                    if delegate?.qrCodeProvider(self, needsValidateCode: code) == true {
                        reportResult(code: code, error: nil)
                    }
                }
            }
        }
    }
    
    // MARK: - KVO
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // only observation here is on the preview. when the preview changes its size
        // reflect that into the video preview layer
        guard let view = object as? UIView, keyPath == "frame" else {
            return
        }
        let bounds = view.bounds
        previewLayer?.bounds = bounds
        previewLayer?.position = CGPoint(x: bounds.midX, y: bounds.midY)
        
    }
    
    // MARK: - Private methods

    private func prepareSession() {
        
        guard captureSession == nil else {
            return
        }
        
        let session = AVCaptureSession()
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            // report error - not allowed
            reportResult(code: nil, error: QRCodeProviderError.permissionDenied)
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            session.addInput(input)
        } catch let error {
            reportResult(code: nil, error: error)
            return
        }
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        guard output.availableMetadataObjectTypes.firstIndex(of: .qr) != nil else {
            // Camera doesn't support QR code scanner :(
            D.error("QR code scanner is not supported")
            reportResult(code: nil, error: QRCodeProviderError.notSupported)
            return
        }
        
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [ .qr ]
        
        if let preview = delegate?.qrCodeProviderCameraPreview(self, forSession: captureSession) {
            // Attach preview layer into the provided view
            let videoLayer = AVCaptureVideoPreviewLayer(session: session)
            
            let bounds = preview.bounds
            videoLayer.videoGravity = .resizeAspectFill
            videoLayer.bounds = bounds
            videoLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
            preview.layer.insertSublayer(videoLayer, at: 0)
            
            // start observing of the frame changes of the preview in case of resizing
            // this can happen for example when the previous screen had navbar, but current doesn't have it
            preview.addObserver(self, forKeyPath: "frame", options: [], context: nil)
            
            self.previewLayer = videoLayer
            self.previewView = preview
        }
        
        self.captureSession = session
    }
    
    private var reported = false // to make sure to report once per "scan start"
    
    private func reportResult(code: String?, error: Error?) {
        
        stopScanner() // when reporting result, we consider scanning done -> stop scanner
        
        DispatchQueue.main.async {
            
            guard self.reported == false else {
                return
            }
            
            self.reported = true
            
            if let code = code {
                self.delegate?.qrCodeProvider(self, didFinishWithCode: code)
            } else if let error = error {
                self.delegate?.qrCodeProvider(self, didFinishWithError: error)
            } else {
                self.delegate?.qrCodeProvider(self, didFinishWithError: QRCodeProviderError.unknown)
            }
        }
    }
}
