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

import Foundation
import PowerAuth2
import LimeCore

/// A class returned as Error from LimeAuth public library interfaces.
public class LimeAuthError: Error {
    
    // MARK: - Construction
    
    /// Initialize object with a nested error.
    ///
    /// Note that you can also use the static `wrap()` method to do the similar job
    /// in a more safe way.
    public init(error: Error) {
        #if DEBUG
        LimeAuthError.validateNestedError(error)
        #endif
        self.nestedError = error
        self.nestedDescription = nil
    }
    
    /// Initialize object with string describing error. This string should be preferred over
    /// the `nestedError` when localization is requested.
    ///
    /// This initializer is useful for situations, when the API produces an error with a known textation and
    /// error processing doesn't depend on other factors, like status code. For example, UI parts of LimeAuth
    /// library are using this initializer to produce errors, which can be directly presented to the user.
    public init(string: String) {
        self.nestedError = nil
        self.nestedDescription = string
    }
    
    /// Initialize object with nesteed error and additional string describing that error.
    /// This string should be preferred over the `nestedError` when localization is requested.
    ///
    /// This initializer is useful for situations, when the API produces an error with a known textation,
    /// but the cause of the failure will be additionally investigated.
    public init(error: Error, string: String) {
        #if DEBUG
        LimeAuthError.validateNestedError(error)
        #endif
        self.nestedError = error
        self.nestedDescription = string
    }
    
    /// Private initializer
    fileprivate init(nestedError: Error?,
                     nestedDescription: String?,
                     httpStatusCode: Int,
                     httpUrlResponse: HTTPURLResponse?,
                     restApiError: LimeAuthRestApiError?) {
        self.nestedError = nestedError
        self.nestedDescription = nestedDescription
        self._httpStatusCode = httpStatusCode
        self.httpUrlResponse = httpUrlResponse
        self.restApiError = restApiError
    }
    
    #if DEBUG
    private static func validateNestedError(_ error: Error) {
        if error is LimeAuthError {
            D.error("You should not embed LimeAuthError into another LimeAuthError object. Please use .wrap() function if you're not sure what type of error is passed to initializer. Error: \(error.localizedDescription)")
        }
    }
    #endif
    
    
    // MARK: - Properties
    
    /// Nested error.
    public let nestedError: Error?
    
    /// Nested direct description for the error.
    public let nestedDescription: String?
    
    /// HTTP status code.
    ///
    /// If value is not set, then it is automatically gathered from
    /// the nested error or from `URLResponse`. Also the nested error must be produced
    /// in PowerAuth2 library and contain embedded `PA2ErrorResponse` object.
    ///
    /// Due to internal getter optimization, the nested objects evaluation is performed only once.
    /// So if you get the value before URL response is set, then the returned value will be incorrect.
    /// You can still later override the calculated value by setting a new one.
    public var httpStatusCode: Int {
        set {
            _httpStatusCode = newValue
        }
        get {
            if _httpStatusCode >= 0 {
                return _httpStatusCode
            } else if let httpUrlResponse = httpUrlResponse {
                _httpStatusCode = Int(httpUrlResponse.statusCode)
            } else if let responseObject = self.powerAuthErrorResponse {
                _httpStatusCode = Int(responseObject.httpStatusCode)
            } else {
                _httpStatusCode = 0
            }
            return _httpStatusCode
        }
    }
    
    /// Private value for httpStatusCode property.
    private var _httpStatusCode: Int = -1
    
    /// A full response received from the server.
    ///
    /// If you set a valid object to this property, then the `httpStatusCode` starts
    /// returning status code from the response. You can set this value in cases that,
    /// it's imporant to investigate a whole response, after the authentication fails.
    ///
    /// Normally, setting `httpStatusCode` is enough for proper handling authentication
    /// errors in LimeAuth UI codes.
    public var httpUrlResponse: HTTPURLResponse?
    
    /// An optional error describing details about REST API failure.
    public var restApiError: LimeAuthRestApiError?
}

// MARK: - Wrapping Error into LimeAuthError

public extension LimeAuthError {
    
    /// Returns LimeAuthError with nested error, or nil if provided error is nil.
    /// If the provided error object is already LimeAuthError, then returns the same object.
    static func wrap(_ error: Error?) -> LimeAuthError? {
        guard let error = error else { return nil }
        if let error = error as? LimeAuthError {
            return error
        }
        return LimeAuthError(error: error)
    }
    
    /// Returns LimeAuthError object with nested error.
    /// If the provided error object is already LimeAuthError, then returns the same object.
    static func wrap(_ error: Error) -> LimeAuthError {
        if let error = error as? LimeAuthError {
            return error
        }
        return LimeAuthError(error: error)
    }
    
    /// Returns LimeAuthError object with nested error and additional nested description.
    /// If the provided error object is already LimeAuthError, then returns copy of the object,
    /// with modiffied nested description.
    static func wrap(_ error: Error, string: String) -> LimeAuthError {
        if let error = error as? LimeAuthError {
            return LimeAuthError(
                nestedError: error.nestedError,
                nestedDescription: string,
                httpStatusCode: error._httpStatusCode,
                httpUrlResponse: error.httpUrlResponse,
                restApiError: error.restApiError)
        }
        return LimeAuthError(error: error, string: string)
    }
}

// MARK: - Computed properties

public extension LimeAuthError {
    
    /// A fallback domain identifier which is returned in situations, when the nested error
    /// is not set, or if it's not kind of NSError object.
    static let limeAuthDomain = "LimeAuthDomain"
    
    
    /// If nestedError is valid, then returns its code
    var code: Int {
        guard let e = nestedError as NSError? else {
            return 0
        }
        return e.code
    }
    
    /// If nestedError is valid, then returns its domain.
    /// Otherwise returns `LimeAuthError.limeAuthDomain`
    var domain: String {
        guard let e = nestedError as NSError? else {
            return LimeAuthError.limeAuthDomain
        }
        return e.domain
    }
    
    /// If nestedError is valid, then returns its user info.
    var userInfo: [String:Any] {
        guard let e = nestedError as NSError? else {
            return [:]
        }
        return e.userInfo
    }
    
    /// Returns true if nested error has information about missing network connection.
    /// The device is typically not connected to the internet.
    var networkIsNotReachable: Bool {
        if self.domain == NSURLErrorDomain || self.domain == kCFErrorDomainCFNetwork as String {
            let ec = CFNetworkErrors(rawValue: Int32(self.code))
            return ec == .cfurlErrorNotConnectedToInternet ||
                ec == .cfurlErrorInternationalRoamingOff ||
                ec == .cfurlErrorDataNotAllowed
        }
        return false
    }
    
    /// Returns true if nested error has information about connection security, like untrusted TLS
    /// certificate, or similar TLS related problems.
    var networkConnectionIsNotTrusted: Bool {
        let domain = self.domain
        if domain == NSURLErrorDomain || domain == kCFErrorDomainCFNetwork as String {
            let code = Int32(self.code)
            if code == CFNetworkErrors.cfurlErrorServerCertificateHasBadDate.rawValue ||
                code == CFNetworkErrors.cfurlErrorServerCertificateUntrusted.rawValue ||
                code == CFNetworkErrors.cfurlErrorServerCertificateHasUnknownRoot.rawValue ||
                code == CFNetworkErrors.cfurlErrorServerCertificateNotYetValid.rawValue ||
                code == CFNetworkErrors.cfurlErrorSecureConnectionFailed.rawValue {
                return true
            }
        }
        return false
    }
    
    /// Returns `PA2ErrorResponse` if such object is embedded in nested error. This is typically useful
    /// for getting response created in the PowerAuth2 library.
    var powerAuthErrorResponse: PA2ErrorResponse? {
        if let responseObject = self.userInfo[PA2ErrorDomain] as? PA2ErrorResponse {
            return responseObject
        }
        return nil
    }
    
    
    var powerAuthRestApiErrorCode: String? {
        if let response = restApiError {
            return response.code
        }
        if let code = powerAuthErrorResponse?.responseObject?.code {
            return code
        }
        return nil
    }
}

extension LimeAuthError: CustomStringConvertible {
    public var description: String {
        
        if let nsne = nestedError as NSError? {
            return nsne.description
        }
        
        if let nd = nestedDescription {
            return nd
        }
        
        var otherResult = "Error  domain: \(domain), code: \(code)"
        
        if httpStatusCode != -1 {
            otherResult += "\nHTTP Status Code: \(httpStatusCode)"
        }
        
        if let raec = powerAuthRestApiErrorCode {
            otherResult += "\nPA REST API Code: \(raec)"
        }
        
        return otherResult
    }
}

extension LimeDebug {
    static func error(_ error: @autoclosure ()->LimeAuthError) {
        LimeDebug.error(error().description)
    }
}
