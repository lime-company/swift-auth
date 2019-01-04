//
// Copyright 2019 Wultra s.r.o.
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

public enum SystemVariant {
    case iPhone(_ gen: Int, _ version: Int)
    case iPad(_ gen: Int, _ version: Int)
    case iPod(_ gen: Int, _ version: Int)
    case watch(_ gen: Int, _ version: Int)
    case simulator
    case unknown
}

public extension UIDevice {
    
    /// Parses type and version of the system
    public static var deviceVersion: SystemVariant = {
        
        var sysinfo = utsname()
        uname(&sysinfo)
        
        guard let sysname = String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)?.trimmingCharacters(in: .controlCharacters).lowercased() else {
            D.error("Cannot parse system name")
            return .unknown
        }
        
        if sysname == "i386" || sysname == "x86_64" {
            return .simulator
        }
        
        do {
            let regexp = try NSRegularExpression(pattern: "([a-z]*)([0-9]*),([0-9]*)")
            let matches = regexp.matches(in: sysname, options: [], range: NSRange(location: 0, length: sysname.count))
            
            guard matches.count == 1 && matches[0].numberOfRanges == 4 else {
                D.error("unknown system format")
                return .unknown
            }
            
            let nsSysname = (sysname as NSString)
            let variant = nsSysname.substring(with: matches[0].range(at: 1))
            guard
                let gen = Int(nsSysname.substring(with: matches[0].range(at: 2))),
                let version = Int(nsSysname.substring(with: matches[0].range(at: 3))) else {
                    D.error("Cannot parse system version")
                    return .unknown
            }
            
            switch variant {
            case "iphone": return .iPhone(gen, version)
            case "ipod": return .iPod(gen, version)
            case "ipad": return .iPad(gen, version)
            case "watch": return .watch(gen, version)
            default:
                D.error("unkwnown version variant")
                return .unknown
            }
            
            
        } catch {
            D.error("Cannot prepare regular expression when parsing system name")
            return .unknown
        }
    }()
    
    /// If device has 1st gen haptic engine (eg iP 6s)
    public static var hasTapticEngine: Bool = {
        
        guard case .iPhone(let gen, let version) = deviceVersion else {
            return false
        }
        
        return gen >= 9 || (gen == 8 && version <= 2) // present in 9th gen and later, in 8th gen present only in 6s & 6s+ (version 1 & 2)
    }()
    
    /// If device has 2nd gen haptic engine (eg iP 7 or 8)
    public static var hasHapticEngine: Bool = {
        
        guard case .iPhone(let gen, _) = deviceVersion else {
            return false
        }
        
        return gen >= 9 // 9 gen devices are ip7 and later
    }()
}
