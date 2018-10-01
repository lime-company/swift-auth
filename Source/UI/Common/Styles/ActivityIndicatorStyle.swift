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

/// The `ActivityIndicatorStyle` structure defines appearance of activity indicator in LimeAuth.
public struct ActivityIndicatorStyle {
    
    /// Activity indicator's style. It's recommended to use `.white` or `.whiteLarge`
    public let style: UIActivityIndicatorView.Style
    
    /// Indicator's color.
    public let color: UIColor
    
    // MARK: - Various options
    
    public struct Options : OptionSet {
        
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        /// If set, then this style will not be applied to the target activity indicator.
        public static let noStyle = Options(rawValue: 1 << 0)
        
        /// Default set of options
        public static let `default`: Options = []
    }
    
    public let options: Options
    
    /// Structure initializer
    public init(
        style: UIActivityIndicatorView.Style,
        color: UIColor,
        options: Options)
    {
        self.style = style
        self.color = color
        self.options = options
    }
    
    /// Returns style for large activity indicator, tinted with given color.
    public static func large(_ color: UIColor) -> ActivityIndicatorStyle {
        return ActivityIndicatorStyle(
            style: .whiteLarge,
            color: color,
            options: .default
        )
    }
    
    /// Returns style for small activity indicator, tinted with given color.
    public static func small(_ color: UIColor) -> ActivityIndicatorStyle {
        return ActivityIndicatorStyle(
            style: .white,
            color: color,
            options: .default
        )
    }
    
    /// Returns style which doesn't affect indicator's appearance at all. This kind of style can be used for cases when actual indicator's
    /// style is applied somehow else. For example, if your application is using a custom storyboards or `UIAppearance` facility,
    /// then it's recommended to do not mix this custom approaches with LimeAuth styles.
    public static var noStyle: ActivityIndicatorStyle {
        return ActivityIndicatorStyle(
            style: .white,
            color: .white,
            options: .noStyle
        )
    }
}
