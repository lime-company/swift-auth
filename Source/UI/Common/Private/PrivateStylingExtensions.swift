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

import Foundation

extension UIImageView {
    
    func setLazyImage(_ image: LazyUIImage?) {
        if let image = image?.optionalImage {
            self.image = image
        }
    }
    
}

extension UIButton {
    
    func applyButtonStyle(_ style: ButtonStyle?) {
        
        guard let style = style else {
            return
        }
        
        // General button
        if let tint = style.tintColor {
            tintColor = tint
        }
        if let titleColor = style.titleColor {
            setTitleColor(titleColor.normal, for: .normal)
            setTitleColor(titleColor.highlighted, for: .highlighted)
        }
        if let font = style.titleFont {
            titleLabel?.font = font
        }
        if let bgColor = style.backgrdoundColor {
            backgroundColor = bgColor.normal
        }
        if let image = style.image {
            if let normal = image.normal.optionalImage {
                setImage(normal, for: .normal)
            }
            if let highlighted = image.highlighted.optionalImage {
                setImage(highlighted, for: .highlighted)
            }
        }
        if let title = style.title {
            setTitle(title, for: .normal)
        }
        self.adjustsImageWhenHighlighted = style.options.contains(.adjustsImageWhenHighlighted)
        self.adjustsImageWhenDisabled = style.options.contains(.adjustsImageWhenDisabled)
        
        // Round corners button
        if let rcSelf = self as? RoundCornersButton {
            if let bgColor = style.backgrdoundColor {
                rcSelf.highlightedBackgroundColor = bgColor.highlighted
            }
            if let borderColor = style.borderColor {
                rcSelf.borderColor = borderColor.normal
                rcSelf.highlightedBorderColor = borderColor.highlighted
            }
            rcSelf.borderCornerRadius = style.borderCornerRadius
			rcSelf.borderWidth = style.borderWidth
            rcSelf.isRounded = style.options.contains(.isRounded)
        }
    }
    
}


extension UIActivityIndicatorView {
    
    func applyIndicatorStyle(_ style: ActivityIndicatorStyle?) {
        guard let style = style else {
            return
        }
        self.activityIndicatorViewStyle = style.style
        self.color = style.color
    }
    
}
