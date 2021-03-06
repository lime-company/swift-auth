//
// Copyright 2018 Wultra s.r.o.
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
///
/// ## Styling notes
///
/// Make sure you know type of button for which you're going to create a style. LimeAuth library is using
/// typically two types of buttons in its default storyboards:
/// * **System buttons**, which are typically more simple to style
///   * Typically, only tint color and font is required to set
///   * This kind of buttons doesn't support custom background colors for disabled or highlighted state.
///     You can try to configure that values, but typically the presentation doesn't work well, due to UIKit internals.
/// * **Custom buttons**, which requires more configuration than system ones
///   * You'll need to setup normal, highlighted & disabled colors separately for title & background colors
///
/// The type of the button is typically mentioned in concrete theme's documentation.

public struct ButtonStyle {
    
    // MARK: - Regular button
    
    /// If set, then color is applied to `UIButton.tintColor`
    public var tintColor: UIColor?
    
    /// If set, then colors are applied to `UIButton.backgroundColor` and `RoundCornersButton.highlightedBackgroundColor`
    public var backgroundColor: MultistateColor?
    
    /// If set, then colors are applied to title colors
    public var titleColor: MultistateColor?
    
    /// If set, then font is applied to button's label
    public var titleFont: UIFont?
    
    /// If set, then text is used as predefined title in button
    public var title: String?
    
    /// If set, then image is used as predefined icon in button
    public var image: MultistateImage?
    
    
    // MARK: - Round cornered button
    
    /// If button is `RoundCornersButton`, then affects width of button's border.
    public var borderWidth: CGFloat
    
    /// If button is `RoundCornersButton`, then changes color of button's border.
    public var borderColor: MultistateColor?
    
    /// If button is `RoundCornersButton`, then affects corner radius of button's border.
    public var borderCornerRadius: CGFloat
    
    
    // MARK: - Various options
    
    public struct Options : OptionSet {
        
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        /// If set, then this style will not be applied to the target button.
        public static let noStyle = Options(rawValue: 1 << 0)
        
        /// If set, and button is `RoundCornersButton`, then it will be rendered as circle.
        public static let isRounded = Options(rawValue: 1 << 1)
    
        /// Affects button's adjustsImageWhenHighlighted property
        public static let adjustsImageWhenHighlighted = Options(rawValue: 1 << 2)
        
        /// Affects button's adjustsImageWhenDisabled property
        public static let adjustsImageWhenDisabled = Options(rawValue: 1 << 3)
        
        /// Default set of options
        public static let `default`: Options = []
    }
    
    public var options: Options
    
    /// Structure initializer
    public init(
        tintColor: UIColor?,
        backgroundColor: MultistateColor?,
        titleColor: MultistateColor?,
        titleFont: UIFont?,
        title: String?,
        image: MultistateImage?,
        borderWidth: CGFloat,
        borderColor: MultistateColor?,
        borderCornerRadius: CGFloat,
        options: Options)
    {
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.title = title
        self.image = image
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.borderCornerRadius = borderCornerRadius
        self.options = options
    }
    
    /// Returns style which doesn't affect button's appearance at all. This kind of style can be used for cases when actual button's
    /// style is applied somehow else. For example, if your application is using a custom storyboards or `UIAppearance` facility,
    /// then it's recommended to do not mix this custom approaches with our ButtonStyle.
    public static var noStyle: ButtonStyle {
        return ButtonStyle(
            tintColor: nil,
            backgroundColor: nil,
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
