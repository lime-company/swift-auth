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

public class LazyUIImage {
    
    private let construction: (()->UIImage?)?
    
    // MARK: - Construction
    
    public init(named name: String, bundle: Bundle? = nil) {
        construction = { ()->UIImage? in
            if let bundle = bundle {
                return UIImage(named: name, in: bundle, compatibleWith: nil)
            } else {
                return UIImage(named: name)
            }
        }
    }
    
    public init(closure: @escaping ()->UIImage?) {
        construction = closure
    }
    
    public init() {
        construction = nil
    }
    
    // MARK: - Properties
    
    public var image: UIImage {
        if let image = construction?() {
            return image
        }
        return UIImage()
    }
    
    public var optionalImage: UIImage? {
        return construction?()
    }
    
    public var hasImage: Bool {
        return construction != nil
    }
    
    // MARK: - Static methods
    
    public static func named(_ name: String, bundle: Bundle? = nil) -> LazyUIImage {
        return LazyUIImage(named: name, bundle: bundle)
    }
    
    public static func build(_ closure: @escaping ()->UIImage?) -> LazyUIImage {
        return LazyUIImage(closure: closure)
    }
    
    public static func empty() -> LazyUIImage {
        return LazyUIImage()
    }
    
    public static func tinted(_ image: LazyUIImage, with color: UIColor) -> LazyUIImage {
        return LazyUIImage {
            guard let image = image.optionalImage else {
                return nil
            }
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            let context = UIGraphicsGetCurrentContext()!
            let rect = CGRect(origin: CGPoint.zero, size: image.size)
            color.setFill()
            image.draw(in: rect)
            context.setBlendMode(.sourceIn)
            context.fill(rect)
            let tintedImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return tintedImage
        }
    }
}
