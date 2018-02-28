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

public protocol CameraAccessProvider {
    static func isCameraAccessGranted() -> Bool
    static func needsCameraAccessApproval() -> Bool
    static func requestCameraAccess(completion: @escaping (Bool)->Void)
}


public extension CameraAccessProvider {
    
    public static func isCameraAccessGranted() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    static func needsCameraAccessApproval() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined
    }
    
    static func requestCameraAccess(completion: @escaping (Bool)->Void) {
        AVCaptureDevice.requestAccess(for: .video) { (approved) in
            DispatchQueue.main.async {
                completion(approved)
            }
        }
    }
}
