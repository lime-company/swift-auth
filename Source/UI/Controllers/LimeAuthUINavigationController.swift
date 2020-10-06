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

/// Custom LimeAuth navigation controller.
/// - Fixing issue when a view controller is pushed while modal dialog (alert) is being presented.
open class LimeAuthUINavigationController: UINavigationController {
    
    /// Whether the issue when a view controller is pushed while modal dialog (alert) is being presented should be fixed.
    /// - true by default.
    open var enablePushWhenModalTransitionFix = true
    
    /// Marks whether view controller is being presented using "present" method
    private(set) var isPresenting = false {
        didSet {
            
            // When presenting is finished and there was an attempt made for pushing a new view controller
            // we will try to push it again (as pushing VC during transition i not possible).
            
            guard isPresenting == false, let vc = storedPushController else {
                return
            }
            
            D.print("Pushing stored view controller after the modal presentation is finished.")
            
            let animate = animateStoredPushController
            storedPushController = nil
            
            // schedule the push to the end of the current stack (to let the current methods to finish).
            DispatchQueue.main.async  {
                self.pushViewController(vc, animated: animate)
            }
        }
    }
    
    private var storedPushController: UIViewController?
    private var animateStoredPushController = false
    
    open override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        isPresenting = true
        super.present(viewControllerToPresent, animated: flag, completion: { [weak self] in
            completion?()
            self?.isPresenting = false
        })
    }
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        // If a modal dialog is being presented while trying to push a view controller
        // a warning is raised to the console and the actual "push" won't occur.
        // In such case, we're storing the view controller that will be pushed once
        // the presentation phased of the modal is over.
        
        if enablePushWhenModalTransitionFix && isPresenting && storedPushController == nil {
            storedPushController = viewController
            animateStoredPushController = animated
            D.print("Attempting to push view controller while modal is under transition. Storing the push for later.")
        } else {
            super.pushViewController(viewController, animated: animated)
        }
    }
    
}
