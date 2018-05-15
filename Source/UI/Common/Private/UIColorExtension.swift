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

internal extension UIColor {
    
    /// Constant 1/255
    static private let invFF: CGFloat = 1.0/255.0
    
    /// Returns UIColor object based on provided hexadecimal color value (0xRRGGBB).
    /// For example. UIColor.rgb(0xFF0000) returns red color.
    static func rgb(_ color: UInt32) -> UIColor {
        return UIColor(
            red:   CGFloat((color >> 16) & 0xFF) * invFF,
            green: CGFloat((color >> 8)  & 0xFF) * invFF,
            blue:  CGFloat( color        & 0xFF) * invFF,
            alpha: 1.0
        )
    }
    
    /// Returns UIColor object based on provided hexadecimal color value with alpha (0xAARRGGBB).
    /// For example. UIColor.rgb(0x80FF0000) returns red color with 50% alpha.
    static func argb(_ color: UInt32) -> UIColor {
        return UIColor(
            red:   CGFloat((color >> 16) & 0xFF) * invFF,
            green: CGFloat((color >> 8)  & 0xFF) * invFF,
            blue:  CGFloat( color        & 0xFF) * invFF,
            alpha: CGFloat((color >> 24) & 0xFF) * invFF
        )
    }
    
}
