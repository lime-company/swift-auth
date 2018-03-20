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

public class OfflineAuthenticationUIOperation: AuthenticationUIOperation {
    
    private var executionBlock: (PowerAuthAuthentication, @escaping ExecutionCallback) -> Operation?
    private var underlyingOperation: Operation?
    
    public init(execution: @escaping (PowerAuthAuthentication, @escaping ExecutionCallback) -> Operation?) {
        self.executionBlock = execution
    }
    
    public func execute(authentication: PowerAuthAuthentication, callback: @escaping ExecutionCallback) {
        if isExecuting {
            callback(nil, LimeAuthError(string: "Operation is already executing"))
            return
        }
        
        isExecuting = true
        isCancelled = false
        
        underlyingOperation = executionBlock(authentication) { (response, error) in
            self.underlyingOperation = nil
            self.isExecuting = false
            
            if self.isCancelled {
                return
            }
            callback(response, error)
        }
    }
    
    public func cancel() {
        if !isCancelled {
            isCancelled = true
            underlyingOperation?.cancel()
            underlyingOperation = nil
        }
    }
    
    public private(set) var isExecuting = false
    
    public private(set) var isCancelled = false
    
    public let isOffline = true
    
    /// Offline operation doesn't need serialization, so we can pretend
    /// that it's already serialized.
    public let isSerialized = true
}
