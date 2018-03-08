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

public enum ErrorActivation {
    
    public struct UIData {
        
        public struct Strings {
            let sceneTitle: String
            let genericError: String
        }
        
        public struct Images {
            let errorIllustration: LazyUIImage
        }
        
        public let strings: Strings
        public let images: Images
        
        public static func fallbackData() -> UIData {
            let strings = Strings(sceneTitle: "Error",
                                  genericError: "The activation did fail. Please try again.")
            let images = Images(errorIllustration: .empty())
            return UIData(strings: strings, images: images)
        }
        
    }
}
