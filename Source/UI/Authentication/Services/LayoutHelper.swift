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

internal class LayoutHelper {
    
    enum PhoneScreenSize {
        /// Device is not a phone
        case none
        /// iPhone 4, 4s
        case verySmall
        /// iPhone 5, 5s, SE
        case small
        /// iPhone 6, 6s, 7, 8, X
        case normal
        /// iPhone 6+, 6s+, 7+, 8+,
        case plus
    }
    
    enum PadScreenSize {
        /// Device is not a tablet
        case none
        /// Normal screen size
        case normal
        /// Plus
        case plus
    }
    
    static var phoneScreenSize: PhoneScreenSize = LayoutHelper.getPhoneScreenSize()
    static var padScreenSize: PadScreenSize = LayoutHelper.getPadScreenSize()
    
    private static func getPhoneScreenSize() -> PhoneScreenSize {
        if UIDevice.current.userInterfaceIdiom == .phone {
            var sr = UIScreen.main.bounds.size
            sr.width  *= UIScreen.main.nativeScale
            sr.height *= UIScreen.main.nativeScale
            if sr.width > 640.0 {
                if sr.width > 1125.0 {
                    // plus versions
                    return .plus
                } else {
                    // non-plus, X
                    return .normal
                }
            } else {
                // 4, 5, SE
                if sr.height > 960.0 {
                    return .small         // 5, 5s, SE
                } else {
                    return .verySmall    // 4, 4s
                }
            }
        }
        return .none
    }
    
    private static func getPadScreenSize() -> PadScreenSize {
        // TODO: Not implemented yet... we don't support ipads now
        return .none
    }
}


