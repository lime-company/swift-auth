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

open class LimeAuthUIBaseViewController: UIViewController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        configureController()
        prepareUI()
    }
    
    /// Overridable method, automatically called from `viewDidLoad()` and before `prepareUI()`
    open func configureController() {
        // Empty
    }
    
    /// Overridable method, automatically called from `viewDidLoad()`
    open func prepareUI() {
        // Empty
    }
    
    /// If true, then background of the controller was already configured
    private var backgroundIsAlreadyConfigured = false
    
    /// Function configures background of this instance of controller, with provided image or color.
    /// If image is used, then image view's content mode will be `.scaleAspectFill`
    public func configureBackground(image: LazyUIImage?, color: UIColor?) {
        // Configuration should be performed only once per controller's lifetime
        if !backgroundIsAlreadyConfigured {
            backgroundIsAlreadyConfigured = true
            // Now apply image or color
            if let image = image {
                if image.hasImage {
                    let imageView = UIImageView(image: image.image)
                    imageView.contentMode = .scaleAspectFill
                    self.view.insertSubview(imageView, at: 0)
                }
            } else if let color = color {
                self.view.backgroundColor = color
            }
        }
    }
    
}
