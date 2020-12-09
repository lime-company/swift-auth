//
// Copyright 2020 Wultra s.r.o.
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

public struct Borders: OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let top =    Borders(rawValue: 1 << 0)
    public static let right =  Borders(rawValue: 1 << 1)
    public static let bottom = Borders(rawValue: 1 << 2)
    public static let left =   Borders(rawValue: 1 << 3)
    
    public static let all: Borders = [.top, .right, .bottom, .left]
    public static let none: Borders = []
    
}

public struct BorderStyle {
    
    public init(width: CGFloat, borderRadius: CGFloat, borders: Borders, color: UIColor) {
        self.width = width
        self.borderRadius = borderRadius
        self.borders = borders
        self.color = color
    }
    
    public let width: CGFloat
    public let borderRadius: CGFloat
    public let borders: Borders
    public let color: UIColor
}
