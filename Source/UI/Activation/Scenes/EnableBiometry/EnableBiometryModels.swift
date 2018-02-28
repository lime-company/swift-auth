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
            let sceneTitle: String
            let touchIdDescription: String
            let faceIdDescription: String
            let enableTouchIdButton: String
            let enableFaceIdButton: String
            let enableLaterButton: String
        }
        
        public struct Images {
            let touchId: LazyUIImage
            let faceId: LazyUIImage
        }
        
        public let strings: Strings
        public let images: Images
        
        public static func fallbackData() -> UIData {
            let strings = Strings(sceneTitle: "",
                                  touchIdDescription: "",
                                  faceIdDescription: "",
                                  enableTouchIdButton: "",
                                  enableFaceIdButton: "",
                                  enableLaterButton: "")
            let images = Images(touchId: .empty(), faceId: .empty())
            return UIData(strings: strings, images: images)
        }
        
    }
}

