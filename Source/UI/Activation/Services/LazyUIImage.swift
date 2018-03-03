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
    
    public init(named name: String) {
        construction = { ()->UIImage? in
            return UIImage(named: name)
        }
    }
    
    public init(closure: @escaping ()->UIImage?) {
        construction = closure
    }
    
    public init() {
        construction = nil
    }
    
    public var image: UIImage {
        if let image = construction?() {
            return image
        }
        return UIImage()
    }
    
    public var hasImage: Bool {
        return construction != nil
    }
    
    public static func named(_ name: String) -> LazyUIImage {
        return LazyUIImage(named: name)
    }
    
    public static func build(_ closure: @escaping ()->UIImage?) -> LazyUIImage {
        return LazyUIImage(closure: closure)
    }
    
    public static func empty() -> LazyUIImage {
        return LazyUIImage()
    }
}
