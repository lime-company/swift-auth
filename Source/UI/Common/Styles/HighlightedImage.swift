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

/// The `HighlightedImage` struct helps with components styling in LimeAuth.
/// The structure contains two images, one for normal and second for highlighted state.
public struct HighlightedImage {
    
    /// Image for normal state
    public let normal: LazyUIImage
    
    /// Image for highlighted state
    public let highlighted: LazyUIImage
    
    
    /// Contains `HighlightedImage` with both images set to `.empty`
    public static var empty: HighlightedImage {
        return HighlightedImage(normal: .empty, highlighted: .empty)
    }
    
    /// Returns `HighlightedImage` with normal part set to desired image.
    /// The highlighted part is set to `.empty`
    public static func normal(_ image: LazyUIImage) -> HighlightedImage {
        return HighlightedImage(normal: image, highlighted: .empty)
    }
    
    /// Returns `HighlightedImage` with highlighted part set to desired image.
    /// The normal part is set to `.empty`
    public static func highlighted(_ image: LazyUIImage) -> HighlightedImage {
        return HighlightedImage(normal: .empty, highlighted: image)
    }
    
    /// Returns `HighlightedImage` with both parts set to the provided image.
    public static func same(_ image: LazyUIImage) -> HighlightedImage {
        return HighlightedImage(normal: image, highlighted: image)
    }
}

