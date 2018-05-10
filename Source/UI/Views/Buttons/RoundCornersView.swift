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

open class RoundCornersView: UIView {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
    }
    
    @objc public var borderCornerRadius: CGFloat = 16 {
        didSet {
            updateCornerRadius()
        }
    }
    
    @objc public var borderWidth: CGFloat    = 2.0 {
        didSet {
            updateCornerRadius()
        }
    }
    
    func updateCornerRadius() {
        layer.cornerRadius = borderCornerRadius
        layer.borderColor = tintColor.cgColor
        layer.borderWidth = borderWidth
    }
}
