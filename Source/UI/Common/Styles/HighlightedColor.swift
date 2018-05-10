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

/// The `HighlightedColor` struct helps with components styling in LimeAuth.
/// The structure contains two colors, one for normal and second for highlighted state.
public struct HighlightedColor {
    
    /// Color for normal state.
    public let normal: UIColor
    
    /// Color for highlighted state.
    public let highlighted: UIColor
    
    /// Contains `HighlightedColor` with both colors set to `.clear`
    public static var clear: HighlightedColor {
        return HighlightedColor(normal: .clear, highlighted: .clear)
    }
    
    /// Returns `HighlightedColor` with normal part set to desired color.
    /// The highlighted part is set to `.clear`
    public static func normal(_ color: UIColor) -> HighlightedColor {
        return HighlightedColor(normal: color, highlighted: .clear)
    }
    
    /// Returns `HighlightedColor` with highlighted part set to desired color.
    /// The normal part is set to `.clear`
    public static func highlighted(_ color: UIColor) -> HighlightedColor {
        return HighlightedColor(normal: .clear, highlighted: color)
    }
    
    /// Returns `HighlightedColor` with both parts set to the provided color.
    public static func same(_ color: UIColor) -> HighlightedColor {
        return HighlightedColor(normal: color, highlighted: color)
    }
    
    /// Returns `HighlightedColor` with two different colors.
    public static func colors(_ normal: UIColor, _ highlighted: UIColor) -> HighlightedColor {
        return HighlightedColor(normal: normal, highlighted: highlighted)
    }
}
