//
// Copyright 2017 Lime - HighTech Solutions s.r.o.
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

open class RoundCornersButton: UIButton {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateBorder()
    }
    
    open override var isHighlighted: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
	
	open override var isEnabled: Bool {
		didSet {
			updateBackgroundColor()
		}
	}
    
    private var storedBackgroundColor: UIColor?
    
    open override var backgroundColor: UIColor? {
        didSet {
            storedBackgroundColor = backgroundColor
            updateBackgroundColor()
        }
    }
    
    /// Changes background color for highlighted button's state.
    @objc public dynamic var highlightedBackgroundColor: UIColor? {
        didSet {
            updateBackgroundColor()
        }
    }

    /// Changes background color for highlighted button's state.
    @objc public dynamic var disabledBackgroundColor: UIColor? {
        didSet {
            updateBackgroundColor()
        }
    }
    
    /// Changes radius of border.
    @objc public dynamic var borderCornerRadius: CGFloat = 0.0 {
        didSet {
            updateBorder()
        }
    }
    
    /// Changes width of border.
    @objc public dynamic var borderWidth: CGFloat = 0.0 {
        didSet {
            updateBorder()
        }
    }
    
    /// Changes color of border.
    @objc public dynamic var borderColor: UIColor? {
        didSet {
            updateBorder()
        }
    }
    
    /// Changes color of border in highlighted state.
    @objc public dynamic var highlightedBorderColor: UIColor? {
        didSet {
            updateBorder()
        }
    }

    /// Changes color of border in highlighted state.
    @objc public dynamic var disabledBorderColor: UIColor? {
        didSet {
            updateBorder()
        }
    }
    
    /// If true, then button is rendered as a circle. The button's width and height should be equal.
    @objc public dynamic var isRounded: Bool = false {
        didSet {
            updateBorder()
        }
    }
    
    /// Contains border's color depending on state of the button (enabled, highlighted).
    /// If such color is not defined, then returns `self.tintColor`.
    private var currentBorderColor: UIColor {
        let color = isEnabled ? (isHighlighted ? highlightedBorderColor : borderColor) : disabledBorderColor
        return color ?? tintColor
    }
    
    /// Contains background's color depending on state of the button (enabled, highlighted).
    /// If such color is not defined, then returns nil.
    private var currentBackgroundColor: UIColor? {
        return isEnabled ? (isHighlighted ? highlightedBackgroundColor : storedBackgroundColor) : disabledBackgroundColor
    }
    
    private func updateBorder() {
        layer.cornerRadius = isRounded ? frame.size.height * 0.5 : borderCornerRadius
        layer.borderColor = currentBorderColor.cgColor
        layer.borderWidth = borderWidth
    }
    
    private func updateBackgroundColor() {
        super.backgroundColor = currentBackgroundColor
        layer.borderColor = currentBorderColor.cgColor
    }
    
}

