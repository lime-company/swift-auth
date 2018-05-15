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

@objc public enum CheckmarkWithActivityState: Int {
    case idle
    case activity
    case success
    case error
}

@objc public protocol CheckmarkWithActivity {
    var state: CheckmarkWithActivityState { get }
    func showIdle(animated: Bool, completion: (()->Void)?)
    func showActivity(animated: Bool, completion: (()->Void)?)
    func showSuccess(animated: Bool, completion: (()->Void)?)
    func showError(animated: Bool, completion: (()->Void)?)
}

/// Extension for default parameters
public extension CheckmarkWithActivity {
    func showIdle(animated: Bool = true, completion: (()->Void)? = nil) {
        self.showIdle(animated: animated, completion: completion)
    }
    
    func showActivity(animated: Bool = true, completion: (()->Void)? = nil) {
        self.showActivity(animated: animated, completion: completion)
    }
    
    func showSuccess(animated: Bool = true, completion: (()->Void)? = nil) {
        self.showSuccess(animated: animated, completion: completion)
    }
    
    func showError(animated: Bool = true, completion: (()->Void)? = nil) {
        self.showError(animated: animated, completion: completion)
    }
}

public struct CheckmarkWithActivityStyle {
    public var indicatorStyle: ActivityIndicatorStyle
    public var successImage: LazyUIImage
    public var failureImage: LazyUIImage
}

/// Default simple implementation for CheckmarkWithActivity
open class CheckmarkWithActivityView: UIView, CheckmarkWithActivity {
    
    // MARK: - ActivityIndicator protocol
    
    public private(set) var state = CheckmarkWithActivityState.idle
    
    open func showIdle(animated: Bool, completion: (()->Void)?) {
        let uiChange = { ()->Void in
            self.state = .idle
            self.activityIndicatorView?.stopAnimating()
            self.activityIndicatorView?.alpha = 0
            self.succesImageView?.alpha = 0
            self.failureImageView?.alpha = 0
        }
        self.applyUiChange(animated: animated, block: uiChange, completion: completion)
    }
    
    open func showActivity(animated: Bool, completion: (()->Void)?) {
        let uiChange = { ()->Void in
            self.state = .activity
            self.activityIndicatorView?.startAnimating()
            self.activityIndicatorView?.alpha = 1
            self.succesImageView?.alpha = 0
            self.failureImageView?.alpha = 0
        }
        self.applyUiChange(animated: animated, block: uiChange, completion: completion)
    }
    
    open func showSuccess(animated: Bool, completion: (()->Void)?) {
        let uiChange = { ()->Void in
            self.state = .activity
            self.activityIndicatorView?.stopAnimating()
            self.activityIndicatorView?.alpha = 0
            self.succesImageView?.alpha = 1
            self.failureImageView?.alpha = 0
        }
        self.applyUiChange(animated: animated, block: uiChange, completion: completion)
    }
    
    open func showError(animated: Bool, completion: (()->Void)?) {
        let uiChange = { ()->Void in
            self.state = .activity
            self.activityIndicatorView?.stopAnimating()
            self.activityIndicatorView?.alpha = 0
            self.succesImageView?.alpha = 0
            self.failureImageView?.alpha = 1
        }
        self.applyUiChange(animated: animated, block: uiChange, completion: completion)
    }
    
    private func applyUiChange(animated: Bool, block: @escaping ()->Void, completion: (()->Void)?) {
        if animated {
            UIView.animate(withDuration: 0.35, animations: block) { (complete) in
                completion?()
            }
        } else {
            block()
            completion?()
        }
    }
    
    public func applyIndicatorStyle(_ style: CheckmarkWithActivityStyle?) {
        activityIndicatorView?.applyIndicatorStyle(style?.indicatorStyle)
        succesImageView?.setLazyImage(style?.successImage)
        failureImageView?.setLazyImage(style?.failureImage)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        showIdle(animated: false)
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView?
    @IBOutlet weak var succesImageView: UIImageView?
    @IBOutlet weak var failureImageView: UIImageView?
}


