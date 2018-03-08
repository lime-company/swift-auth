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

import Foundation
import AVFoundation

public protocol QRCodeProviderDelegate: class {
    
    func qrCodeProvider(_ provider: QRCodeProvider, didFinishWithError error: Error)
    func qrCodeProvider(_ provider: QRCodeProvider, didFinishWithCode code: String)
    
    func qrCodeProvider(_ provider: QRCodeProvider, needsValidateCode code: String) -> Bool
    func qrCodeProviderCameraPreview(_ provider: QRCodeProvider, forSession session: AVCaptureSession?) -> UIView?
}

public protocol QRCodeProvider: CameraAccessProvider {
        
    weak var delegate: QRCodeProviderDelegate? { get set }
 
    var isScannerStarted: Bool { get }
    
    func startScanner()
    func stopScanner()
}


public class QRCodeScanner: NSObject, QRCodeProvider, AVCaptureMetadataOutputObjectsDelegate {
    
    public private(set) var captureSession: AVCaptureSession!

    public private(set) weak var previewLayer: AVCaptureVideoPreviewLayer?
    
    
    // MARK: - QRCodeProvider protocol
    
    public weak var delegate: QRCodeProviderDelegate?
    
    
    public var isScannerStarted: Bool {
        return captureSession?.isRunning ?? false
    }

    
    public func startScanner() {
        if !isScannerStarted {
            prepareSession()
            captureSession?.startRunning()
        }
    }
    
    
    public func stopScanner() {
        if isScannerStarted {
            captureSession?.stopRunning()
        }
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate protocol
    
    @objc public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for item in metadataObjects {
            if let mrCodeItem = item as? AVMetadataMachineReadableCodeObject {
                if mrCodeItem.type == .qr, let code = mrCodeItem.stringValue {
                    if delegate?.qrCodeProvider(self, needsValidateCode: code) ?? false {
                        reportResult(code: code, error: nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Private methods

    private func prepareSession() {
        if captureSession != nil {
            return
        }
        captureSession = AVCaptureSession()
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            // report error - not allowed
            reportResult(code: nil, error: nil)
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            captureSession.addInput(input)
        } catch let error as NSError {
            reportResult(code: nil, error: error)
            return
        } catch {
            // report error
            reportResult(code: nil, error: nil)
            return
        }
        
        let output = AVCaptureMetadataOutput()
        captureSession.addOutput(output)
        guard output.availableMetadataObjectTypes.index(of: .qr) != nil else {
            // Camera doesn't support QR code scanner :(
            D.print("QR code scanner is not supported")
            reportResult(code: nil, error: nil)
            return
        }
        
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [ .qr ]
        
        
        if let preview = delegate?.qrCodeProviderCameraPreview(self, forSession: captureSession) {
            // Attach preview layer into the provided view
            let videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            
            let bounds = preview.bounds
            videoLayer.videoGravity = .resizeAspectFill
            videoLayer.bounds = bounds
            videoLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
            preview.layer.insertSublayer(videoLayer, at: 0)
            
            self.previewLayer = videoLayer
        }
    }
    
    
    private func reportResult(code: String?, error: Error?) {
        DispatchQueue.main.async {
            if let code = code {
                self.delegate?.qrCodeProvider(self, didFinishWithCode: code)
            } else if let error = error {
                self.delegate?.qrCodeProvider(self, didFinishWithError: error)
            } else {
                // dispatch generic error
            }
        }
    }
}
