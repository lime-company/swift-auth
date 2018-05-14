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

/// The `TextFieldStyle` structure defines appearance of text field in LimeAuth.
public struct TextFieldStyle {
    
    // MARK: - Regular text field
    
    /// If set, then color is applied to `UITextField.tintColor`
    public let tintColor: UIColor?
    
    /// If set, then color is applied to `UITextField.backgroundColor`
    public let backgroundColor: UIColor?
    
    /// If set, then colors are applied to `UITextField.textColor`
    public let textColor: UIColor?
    
    /// If set, then colors are applied to `UITextField.textColor`
    public let textFont: UIFont?
    
    
    /// Affects width of text fields's border. Applied to text field's layer.
    public let borderWidth: CGFloat
    
    /// Changes color of text field's border. Applied to text field's layer.
    public let borderColor: UIColor?
    
    /// Affects corner radius of text field's border. Appled to view's layer.
    public let borderCornerRadius: CGFloat
    
    /// System keyboard's appearance
    public var keyboardAppearance: UIKeyboardAppearance
    
    // MARK: - Various options
    
    public struct Options : OptionSet {
        
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        /// If set, then this style will not be applied to the target text field.
        static let noStyle = Options(rawValue: 1 << 0)

        /// Default set of options
        static let `default`: Options = []
    }
    
    public let options: Options
 
    /// Returns style which doesn't affect text field's appearance at all. This kind of style can be used for cases when actual
    /// style is applied somehow else. For example, if your application is using a custom storyboards or `UIAppearance` facility,
    /// then it's recommended to do not mix this custom approaches with LimeAuth styles.
    public static var noStyle: TextFieldStyle {
        return TextFieldStyle(
            tintColor: nil,
            backgroundColor: nil,
            textColor: nil,
            textFont: nil,
            borderWidth: 0.0,
            borderColor: nil,
            borderCornerRadius: 0.0,
            keyboardAppearance: .default,
            options: [.noStyle]
        )
    }
    
}
