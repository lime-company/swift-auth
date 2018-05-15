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

/// The `LimeAuthUIBaseViewController` is a base class for all controllers used in LimeAuth library.
///
open class LimeAuthUIBaseViewController: UIViewController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        configureController()
        prepareUI()
    }
    
    
    // MARK: - Overridable functions
    
    /// Overridable method, automatically called from `viewDidLoad()` and before `prepareUI()`
    open func configureController() {
        // Empty
    }
    
    /// Overridable method, automatically called from `viewDidLoad()`
    open func prepareUI() {
        // Empty
    }
    
    // MARK: - Status bar
    
    internal static var commonPreferredStatusBarStyle: UIStatusBarStyle = .default

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return LimeAuthUIBaseViewController.commonPreferredStatusBarStyle
    }

    // MARK: - Controller's background
    
    /// If true, then background of the controller was already configured
    private var backgroundIsAlreadyConfigured = false
    
    /// Function configures background of controller, with provided image and color.
    /// If you provide both parameters, then both are applied:
    /// - the color is set to controller's main view's background color
    /// - `UIImageView` is constructed for image and inserted as first subview to `parentViewForBackgroundImageView`.
    ///   The `.scaleAspectFill` content mode will be used for that constructed image view and will fill a whole
    ///   area of `parentViewForBackgroundImageView`
    public func configureBackground(image: LazyUIImage?, color: UIColor?) {
        // Configuration should be performed only once per controller's lifetime
        if !backgroundIsAlreadyConfigured {
            backgroundIsAlreadyConfigured = true
            // Now apply image if is provided
            if let image = image?.optionalImage {
                // Build image view
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFill
                imageView.translatesAutoresizingMaskIntoConstraints = false
                self.parentViewForBackgroundImageView.insertSubview(imageView, at: 0)
                self.backgroundImageView = imageView
                // Build constraints
                let bindings = [ "image" : imageView ]
                self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[image]|", options: [], metrics: nil, views: bindings))
                self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[image]|", options: [], metrics: nil, views: bindings))
            }
            // And color
            if let color = color {
                self.view.backgroundColor = color
            }
        }
    }
    
    /// Contains a parent view for background image view, required for background image presentation.
    /// You can override this getter in subclass. By default contains `self.view`
    open var parentViewForBackgroundImageView: UIView {
        return self.view
    }
    
    /// If controller's background was configured with image, then this property contains a view with that image.
    public private(set) weak var backgroundImageView: UIImageView?
}
