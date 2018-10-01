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

extension LimeAuthAuthenticationUITheme {
    
    var styleForCheckmarkWithActivity: CheckmarkWithActivityStyle {
        return CheckmarkWithActivityStyle(
            indicatorStyle: common.activityIndicator,
            successImage: images.successImage,
            failureImage: images.failureImage
        )
    }
    
    var layerStyleFromAuthenticationCommon: GenericLayerStyle? {
        guard let borderColor = common.passwordBorderColor else {
            return nil
        }
        guard common.passwordBorderWidth > 0.0 else {
            return nil
        }
        return GenericLayerStyle(
            borderWidth: common.passwordBorderWidth,
            cornerRadius: common.passwordBorderCornerRadius,
            borderColor: borderColor)
    }
}


extension UIImageView {
    
    func setLazyImage(_ image: LazyUIImage?, fallback: LazyUIImage? = nil) {
        if let image = image?.optionalImage {
            self.image = image
        }
        if let image = fallback?.optionalImage {
            self.image = image
        }
    }
    
}


extension UIActivityIndicatorView {
    
    func applyIndicatorStyle(_ style: ActivityIndicatorStyle?) {
        guard let style = style else {
            return
        }
        if style.options.contains(.noStyle) {
            return
        }
        
        self.style = style.style
        self.color = style.color
    }
}


extension UITextField {
    
    func applyTextFieldStyle(_ style: TextFieldStyle?) {
        guard let style = style else {
            return
        }
        if style.options.contains(.noStyle) {
            return
        }
        
        // Apply style
        if let tint = style.tintColor {
            self.tintColor = tint
        }
        if let textColor = style.textColor {
            self.textColor = textColor
        }
        if let bgColor = style.backgroundColor {
            self.backgroundColor = bgColor
        }
        if let font = style.textFont {
            self.font = font
        }
        let layer = self.layer
        layer.borderWidth = style.borderWidth
        layer.cornerRadius = style.borderCornerRadius
        if let color = style.borderColor {
            layer.borderColor = color.cgColor
        }
        self.keyboardAppearance = style.keyboardAppearance
    }
    
}


extension UIView {
    
    func applyLayerStyle(_ style: GenericLayerStyle?) {
        guard let style = style else {
            return
        }
        let layer = self.layer
        layer.borderWidth = style.borderWidth
        layer.borderColor = style.borderColor.cgColor
        layer.cornerRadius = style.cornerRadius
    }
    
}
