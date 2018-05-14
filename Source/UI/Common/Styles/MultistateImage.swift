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

/// The `MultistateImage` struct helps with components styling in LimeAuth.
/// The structure contains two images, one for normal and second for highlighted state.
public struct MultistateImage {
    
    /// Image for normal state
    public let normal: LazyUIImage
    
    /// Image for highlighted state
    public let highlighted: LazyUIImage
    
    /// Image for disabled state
    public let disabled: LazyUIImage
    
    /// Contains `MultistateImage` with all parts set to `.empty`
    public static var empty: MultistateImage {
        return MultistateImage(normal: .empty, highlighted: .empty, disabled: .empty)
    }
    
    /// Returns `MultistateImage` with normal part set to desired image.
    /// The highlighted and disabled parts are set to `.empty`
    public static func normal(_ image: LazyUIImage) -> MultistateImage {
        return MultistateImage(normal: image, highlighted: .empty, disabled: .empty)
    }
    
    /// Returns `MultistateImage` with highlighted part set to desired image.
    /// The normal and disabled parts are set to `.empty`
    public static func highlighted(_ image: LazyUIImage) -> MultistateImage {
        return MultistateImage(normal: .empty, highlighted: image, disabled: .empty)
    }
    
    /// Returns `MultistateImage` with all parts set to the provided image.
    public static func same(_ image: LazyUIImage) -> MultistateImage {
        return MultistateImage(normal: image, highlighted: image, disabled: image)
    }
    
    /// Returns `MultistateImage` with provided images. If highlighted or disabled color is nil, then `.empty` object is applied.
    public static func images(_ normal: LazyUIImage, _ highlighted: LazyUIImage? = nil, _ disabled: LazyUIImage? = nil) -> MultistateImage {
        return MultistateImage(
            normal: normal,
            highlighted: highlighted ?? .empty,
            disabled: disabled ?? .empty
        )
    }
}

