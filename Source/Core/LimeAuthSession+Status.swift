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

public extension LimeAuthSession {
    
    /// Notification is fired after the state of the activation change.
    public static let didChangeActivationStatus = Notification.Name(rawValue: "LimeAuthSession_didChangeActivationStatus")    

    /// The method updates activation status from the server.
    public func fetchActivationStatus(completion: @escaping (PA2ActivationStatus?, [AnyHashable : Any]?, LimeAuthError?) -> Void) -> Operation {
        return statusFetcher.updateActivationStatus(completion: completion)
    }
    
    /// Contains last fetched activation status object or nil if status has not been fetched yet.
    public var lastFetchedActivationStatus: PA2ActivationStatus? {
        if powerAuth.hasValidActivation() {
            return self.statusFetcher.lastFetchedData?.status
        }
        return nil
    }
    
    /// Contains last fetched data received together with activation status.
    ///
    /// Note that this kind of data depends on actual server implementation.
    public var lastFetchedActivationStatusData: [AnyHashable : Any]? {
        if powerAuth.hasValidActivation() {
            return self.statusFetcher.lastFetchedData?.data
        }
        return nil
    }
    
    /// Contains true if application should update activation status. This is typically when the status data
    /// has not been fetched yet, or if last update failed on error.
    public var shouldUpdateActivationStatus: Bool {
        if powerAuth.hasValidActivation() {
            return statusFetcher.shouldUpdateActivationStatus
        }
        return false
    }
    
    /// Performs a silent update for activation status. If the silent update fails, then the update will
    /// be executed before the next important operation and `shouldUpdateActivationStatus` will contain true.
    public func setNeedUpdateActivationStatus() {
        if powerAuth.hasValidActivation() {
            statusFetcher.setNeedUpdateActivationStatus()
        }
    }
    
}
