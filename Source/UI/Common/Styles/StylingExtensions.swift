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

import Foundation

public extension UIButton {
    
    public func applyButtonStyle(_ style: ButtonStyle?) {
        
        guard let style = style else {
            return
        }
        if style.options.contains(.noStyle) {
            return
        }
        
        // General button
        if let tint = style.tintColor {
            tintColor = tint
        }
        if let titleColor = style.titleColor {
            setTitleColor(titleColor.normal, for: .normal)
            setTitleColor(titleColor.highlighted, for: .highlighted)
            setTitleColor(titleColor.disabled, for: .disabled)
        }
        if let font = style.titleFont {
            titleLabel?.font = font
        }
        if let bgColor = style.backgroundColor {
            backgroundColor = bgColor.normal
        }
        if let image = style.image {
            setImage(image.normal.optionalImage, for: .normal)
            setImage(image.highlighted.optionalImage, for: .highlighted)
            setImage(image.disabled.optionalImage, for: .disabled)
        }
        if let title = style.title {
            setTitle(title, for: .normal)
        }
        self.adjustsImageWhenHighlighted = style.options.contains(.adjustsImageWhenHighlighted)
        self.adjustsImageWhenDisabled = style.options.contains(.adjustsImageWhenDisabled)
        
        // Round corners button
        if let rcSelf = self as? RoundCornersButton {
            if let backgroundColor = style.backgroundColor {
                rcSelf.highlightedBackgroundColor = backgroundColor.highlighted
                rcSelf.disabledBackgroundColor = backgroundColor.disabled
            }
            if let borderColor = style.borderColor {
                rcSelf.borderColor = borderColor.normal
                rcSelf.highlightedBorderColor = borderColor.highlighted
                rcSelf.disabledBorderColor = borderColor.disabled
            }
            rcSelf.borderCornerRadius = style.borderCornerRadius
            rcSelf.borderWidth = style.borderWidth
            rcSelf.isRounded = style.options.contains(.isRounded)
        }
    }
    
}
