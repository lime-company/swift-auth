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

/// A class returned as Error when error occurs
public class LimeAuthError: Error {
    
    public static let limeAuthDomain = "limeAuthDomain"
    
    /// Status code from `HTTPURLResponse` or from `PA2ErrorResponse`
    public var httpStatusCode: Int {
        if _httpStatusCode != 0 {
            return _httpStatusCode
        } else if let responseObject = self.powerAuthErrorResponse {
            _httpStatusCode = Int(responseObject.httpStatusCode)
            return _httpStatusCode
        }
        return 0
    }
    
    private var _httpStatusCode: Int = 0
    
    /// A full response received from server
    public var urlResponse: URLResponse? {
        didSet {
            if let resp = urlResponse as? HTTPURLResponse {
                _httpStatusCode = resp.statusCode
            }
        }
    }
    
    /// Contains HTTP response with error payload
    //var errorResponse: MTokenErrorResponse?
    
    /// Nested error.
    public let nestedError: Error?
    
    /// Nested direct description for the error.
    public let nestedDescription: String?
    
    /// If nestedError is valid, then returns its code
    public var code: Int {
        guard let e = nestedError as NSError? else {
            return 0
        }
        return e.code
    }
    
    /// If nestedError is valid, then returns its domain
    public var domain: String {
        guard let e = nestedError as NSError? else {
            return LimeAuthError.limeAuthDomain
        }
        return e.domain
    }
    
    /// If nestedError is valid, then returns its user info.
    public var userInfo: [String:Any] {
        guard let e = nestedError as NSError? else {
            return [:]
        }
        return e.userInfo
    }
    
    /// Initialize object with nested error
    public init(error: Error) {
        self.nestedError = error
        self.nestedDescription = nil
    }
    
    /// Initialize object with string describing error.
    public init(string: String) {
        self.nestedError = nil
        self.nestedDescription = string
    }
    
    /// Initialize object with nesteed error and additional string describing
    /// that error.
    public init(error: Error, string: String) {
        self.nestedError = error
        self.nestedDescription = string
    }
    
//    init(response: MTokenErrorResponse) {
//        self.errorResponse = response
//    }
}

public extension LimeAuthError {
    
    /// Returns true if nested error has information about missing network connection.
    /// The device is typically not connected to the internet.
    public var networkIsNotReachable: Bool {
        if self.domain == NSURLErrorDomain || self.domain == kCFErrorDomainCFNetwork as String {
            let ec = CFNetworkErrors(rawValue: Int32(self.code))
            return ec == .cfurlErrorNotConnectedToInternet ||
                ec == .cfurlErrorInternationalRoamingOff ||
                ec == .cfurlErrorDataNotAllowed
        }
        return false
    }
    
    /// Returns `PA2ErrorResponse` if such object is embedded in nested error. This is typically useful
    /// for getting response created in the PowerAuth2 library.
    public var powerAuthErrorResponse: PA2ErrorResponse? {
        if let responseObject = self.userInfo[PA2ErrorDomain] as? PA2ErrorResponse {
            return responseObject
        }
        return nil
    }
}
