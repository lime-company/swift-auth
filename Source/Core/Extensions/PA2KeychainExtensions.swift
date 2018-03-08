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
import PowerAuth2

// MARK: - Keychain simplification -

public extension PA2Keychain {
    
    private static let jsonEncoder: JSONEncoder = {
        let enc = JSONEncoder()
        enc.dataEncodingStrategy = .base64
        enc.dateEncodingStrategy = .millisecondsSince1970
        return enc
    }()
    
    private static let jsonDecoder: JSONDecoder = {
        let dec = JSONDecoder()
        dec.dataDecodingStrategy = .base64
        dec.dateDecodingStrategy = .millisecondsSince1970
        return dec
    }()
    
    public func update<T: CodableToDictionary>(value: T, for key: String) {
        if let encoded = self.encode(value) {
            if self.containsData(forKey: key) {
                let _ = self.updateValue(encoded, forKey: key)
            } else {
                let _ = self.addValue(encoded, forKey: key)
            }
        }
    }
    
    public func value<T: CodableToDictionary>(for key: String) -> T? {
        guard let data = self.data(forKey: key, status: nil)
            else { return nil }
        return self.decode(data)
    }
    
    // Private methods
    
    private func encode<T: CodableToDictionary>(_ value: T) -> Data? {
        let dict = T.encodeToDictionary(value)
        return try? PA2Keychain.jsonEncoder.encode(dict)
    }
    
    private func decode<T: CodableToDictionary>(_ data: Data) -> T? {
        guard let dict = try? PA2Keychain.jsonDecoder.decode([String:T].self, from: data)
            else { return nil }
        return T.decodeFromDictionary(dict)
    }
}

// MARK: -

public protocol CodableToDictionary {
    static func encodeToDictionary(_ value: Self) -> [String: Self]
    static func decodeFromDictionary(_ dict: [String: Self]) -> Self?
}

// MARK: - CodableToDictionary for common types

extension String : CodableToDictionary {
    public static func encodeToDictionary(_ value: String) -> [String: String] { return ["$S" : value] }
    public static func decodeFromDictionary(_ dict: [String: String]) -> String? { return dict["$S"] }
}

extension Int : CodableToDictionary {
    public static func encodeToDictionary(_ value: Int) -> [String: Int] { return ["$I" : value] }
    public static func decodeFromDictionary(_ dict: [String: Int]) -> Int? { return dict["$I"] }
}

extension Double : CodableToDictionary {
    public static func encodeToDictionary(_ value: Double) -> [String: Double] { return ["$F" : value] }
    public static func decodeFromDictionary(_ dict: [String: Double]) -> Double? { return dict["$F"] }
}

extension Data : CodableToDictionary {
    public static func encodeToDictionary(_ value: Data) -> [String: Data] { return ["$D" : value] }
    public static func decodeFromDictionary(_ dict: [String: Data]) -> Data? { return dict["$D"] }
}

extension Date : CodableToDictionary {
    public static func encodeToDictionary(_ value: Date) -> [String: Date] { return ["$T" : value] }
    public static func decodeFromDictionary(_ dict: [String: Date]) -> Date? { return dict["$T"] }
}

extension Bool : CodableToDictionary {
    public static func encodeToDictionary(_ value: Bool) -> [String: Bool] { return ["$B" : value] }
    public static func decodeFromDictionary(_ dict: [String: Bool]) -> Bool? { return dict["$B"] }
}
