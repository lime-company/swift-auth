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

/// The `ButtonStyle` structure defines appearance of button in LimeAuth. The structure contains
/// properties for regular UIButton, but also for our custom `RoundCornersButton` class.
public struct ButtonStyle {
    
    // MARK: - Regular button
    
    /// If set, then color is applied to `UIButton.tintColor`
    public let tintColor: UIColor?
    
    /// If set, then colors are applied to `UIButton.backgroundColor` and `RoundCornersButton.highlightedBackgroundColor`
    public let backgrdoundColor: HighlightedColor?
    
    /// If set, then colors are applied to title colors
    public let titleColor: HighlightedColor?
    
    /// If set, then font is applied to button's label
    public let titleFont: UIFont?
    
    /// If set, then text is used as predefined title in button
    public let title: String?
    
    /// If set, then text is used as predefined icon in button
    public let image: HighlightedImage?
    
    
    // MARK: - Round cornered button
    
    /// If button is `RoundCornersButton`, then affects width of button's border.
    public let borderWidth: CGFloat
    
    /// If button is `RoundCornersButton`, then changes color of button's border.
    public let borderColor: HighlightedColor?
    
    /// If button is `RoundCornersButton`, then affects corner radius of button's border.
    public let borderCornerRadius: CGFloat
    
    
    // MARK: - Various options
    
    public struct Options : OptionSet {
        
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        /// If set, then this style will not be applied to the target button.
        static let noStyle = Options(rawValue: 1 << 0)
        
        /// If set, and button is `RoundCornersButton`, then it will be rendered as circle.
        static let isRounded = Options(rawValue: 1 << 1)
    
        /// Affects button's adjustsImageWhenHighlighted property
        static let adjustsImageWhenHighlighted = Options(rawValue: 1 << 2)
        
        /// Affects button's adjustsImageWhenDisabled property
        static let adjustsImageWhenDisabled = Options(rawValue: 1 << 3)
        
        /// For `RoundCornersButton` affects adjustsAlphaWhenDisabled property.
        static let adjustsAlphaWhenDisabled = Options(rawValue: 1 << 4)
        
        /// Default set of options
        static let `default`: Options = [.adjustsImageWhenHighlighted, .adjustsImageWhenDisabled, .adjustsAlphaWhenDisabled]
    }
    
    public let options: Options
    
    /// Returns style which doesn't affect button's appearance at all. This kind of style can be used for cases when actual button's
    /// style is applied somehow else. For example, if your application is using a custom storyboards or `UIAppearance` facility,
    /// then it's recommended to do not mix this custom approaches with our ButtonStyle.
    public static var noStyle: ButtonStyle {
        return ButtonStyle(
            tintColor: nil,
            backgrdoundColor: nil,
            titleColor: nil,
            titleFont: nil,
            title: nil,
            image: nil,
            borderWidth: 0.0,
            borderColor: nil,
            borderCornerRadius: 0.0,
            options: [.noStyle])
    }
    
}
