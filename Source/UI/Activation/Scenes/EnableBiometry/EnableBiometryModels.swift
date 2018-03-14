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

public enum EnableBiometry {
    
    public struct UIData {
        
        public struct Strings {
            let touchIdSceneTitle: String
            let faceIdSceneTitle: String
            let touchIdDescription: String
            let faceIdDescription: String
            let enableTouchIdButton: String
            let enableFaceIdButton: String
            let enableLaterButton: String
        }
        
        public struct Images {
            let biometry: LazyUIImage
        }
        
        public let strings: Strings
        public let images: Images
        
        public static func fallbackData() -> UIData {
            let strings = Strings(
                touchIdSceneTitle: "Confirm payments by fingerprint",
                faceIdSceneTitle: "Confirm payments by face",
                touchIdDescription: "You can sign in and confirm operations just with your fingerprint.",
                faceIdDescription: "You can sign in and confirm operations just with your face.",
                enableTouchIdButton: "Allow Touch ID",
                enableFaceIdButton: "Allow Face ID",
                enableLaterButton: "Not now, thank you"
            )
            let images = Images(biometry: .empty())
            return UIData(strings: strings, images: images)
        }
        
    }
}

