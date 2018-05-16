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

/// The `MultistateColor` struct helps with components styling in LimeAuth.
/// The structure contains three colors, for normal, highlighted and disabled state.
public struct MultistateColor {
    
    /// Color for normal state.
    public let normal: UIColor
    
    /// Color for highlighted state.
    public let highlighted: UIColor?
    
    /// Color for disabled state.
    public let disabled: UIColor?
    
    /// Structure initializer
    public init(
        normal: UIColor,
        highlighted: UIColor?,
        disabled: UIColor?)
    {
        self.normal = normal
        self.highlighted = highlighted
        self.disabled = disabled
    }
    
    /// Contains `MultistateColor` with both colors set to `.clear`
    public static var clear: MultistateColor {
        return MultistateColor(normal: .clear, highlighted: nil, disabled: nil)
    }
    
    /// Returns `MultistateColor` with normal part set to desired color.
    /// The highlighted part is set to `.clear`
    public static func normal(_ color: UIColor) -> MultistateColor {
        return MultistateColor(normal: color, highlighted: .clear, disabled: .clear)
    }
    
    /// Returns `MultistateColor` with highlighted part set to desired color.
    /// The normal and disabled part is set to `.clear`
    public static func highlighted(_ color: UIColor) -> MultistateColor {
        return MultistateColor(normal: .clear, highlighted: color, disabled: .clear)
    }
    
    /// Returns `MultistateColor` with disabled part set to desired color.
    /// The normal and disabled part is set to `.clear`
    public static func disabled(_ color: UIColor) -> MultistateColor {
        return MultistateColor(normal: .clear, highlighted: .clear, disabled: color)
    }
    
    /// Returns `MultistateColor` with both parts set to the provided color.
    public static func same(_ color: UIColor) -> MultistateColor {
        return MultistateColor(normal: color, highlighted: color, disabled: color)
    }
    
    /// Returns `MultistateColor` with provided colors.
    public static func colors(_ normal: UIColor, _ highlighted: UIColor? = nil, _ disabled: UIColor? = nil) -> MultistateColor {
        return MultistateColor(normal: normal, highlighted: highlighted, disabled: disabled)
    }
}
