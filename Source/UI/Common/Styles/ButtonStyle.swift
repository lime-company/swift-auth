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

public struct ButtonStyle {
    
    // Regular button
    public let tintColor: UIColor?
    public let backgrdoundColor: HighlightedColor?
    public let titleColor: HighlightedColor?
    public let titleFont: UIFont?
    
    public let title: String?
    public let image: HighlightedImage?
    
    // Round cornered button
    public let borderWidth: CGFloat
    public let borderColor: HighlightedColor?
    public let borderCornerRadius: CGFloat
    
    public static var noStyle: ButtonStyle {
        return ButtonStyle(tintColor: nil,
                           backgrdoundColor: nil,
                           titleColor: nil,
                           titleFont: nil,
                           title: nil,
                           image: nil,
                           borderWidth: 0.0,
                           borderColor: nil,
                           borderCornerRadius: 0.0)
    }
    
}
