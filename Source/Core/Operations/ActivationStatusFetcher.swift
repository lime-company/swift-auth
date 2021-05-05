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

internal class ActivationStatusFetcher {
    
    private unowned var authSession: LimeAuthSession
    
    private var lock = Lock()
    
    init(session: LimeAuthSession) {
        self.authSession = session
    }
    
    typealias FetchStatusCompletion = (PowerAuthActivationStatus?, [AnyHashable : Any]?, LimeAuthError?) -> Void
    typealias FetchStatusData = (status: PowerAuthActivationStatus, data: [AnyHashable: Any]?)
    
    // MARK: - Last fetched status
    
    private var _lastFetchedData: FetchStatusData?

    private var shouldUpdate: Bool = true

    /// Thread safe access to lastFetchedData
    internal var lastFetchedData: FetchStatusData? {
        return lock.synchronized {
            return _lastFetchedData
        }
    }
    
    internal func clearLastFetchedData() {
        lock.synchronized {
            _lastFetchedData = nil
        }
    }
    
    ///
    internal func setNeedUpdateActivationStatus() {
        let _ = self.updateActivationStatus { (status, _, error) in
            if status == nil || error != nil {
                self.lock.synchronized {
                    self.shouldUpdate = true
                }
            }
        }
    }
    
    /// Contains true if application shoulw update status
    internal var shouldUpdateActivationStatus: Bool {
        return lock.synchronized {
            return self.shouldUpdate == true || _lastFetchedData == nil
        }
    }
    
    /// Commits new fetched data to internal, lock-protected variable
    private func updateLastFetchedData(_ data: FetchStatusData) {
        let (fireStatusChangedNotification, removeLocal) = lock.synchronized { ()->(Bool, Bool) in
            
            let oldStatus = self._lastFetchedData?.status.state              // status before fetch
            let newStatus = data.status.state                                // current status that was just fetched
            let statusChanged = oldStatus != nil && oldStatus! != newStatus  // status can change only when previously set
            
            // if local activation should be removed
            let removeLocal = newStatus == .removed && self.authSession.configuration.removeLocalActivationWhenRemovedOnServer
            
            self._lastFetchedData = data
            self.shouldUpdate = false
            
            return (statusChanged, removeLocal)
        }
        // Fire notification about the status change if required.
        if fireStatusChangedNotification {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: LimeAuthSession.didChangeActivationStatus, object: data.status)
            }
        }
        // Remove local activation if required.
        if removeLocal {
            let session = authSession
            DispatchQueue.main.async {
                // This will annulate _lastFetchData and fire didRemoveActivation notification
                session.removeActivationLocal()
            }
        }
    }
    
    // One operation that is actually performing the fetch. Other parallel operation will just use it as dependency
    private weak var ongoingFetch: FetchOperation?
    // Semaphore to prevent race conditions when crating fetch operations
    private var schedulingLock = Lock()

    /// Updates activation status
    internal func updateActivationStatus(completion: @escaping FetchStatusCompletion) -> Operation {
        
        let operation = FetchOperation(statusChecker: self, completion: completion)
        
        // lock ongoingFetch manipulation and access to prevent race condition
        schedulingLock.synchronized {
            if let fetch = ongoingFetch, fetch.isFinished == false, fetch.isCancelled == false {
                operation.addDependency(fetch)
            } else {
                ongoingFetch = operation
            }
        }
        
        return authSession.addOperationToQueue(operation, serialized: false)
    }
    
    
    /// Helper operation class retrieving status from the server
    private class FetchOperation: AsyncOperation {
        
        private var error: LimeAuthError?
        private var result: FetchStatusData?
        
        private var completion: FetchStatusCompletion
        private weak var statusChecker: ActivationStatusFetcher?
        private weak var fetchTask: PowerAuthOperationTask?
        
        init(statusChecker: ActivationStatusFetcher, completion: @escaping FetchStatusCompletion) {
            self.statusChecker = statusChecker
            self.completion = completion
        }
        
        // When operation starts
        override func started() {
            
            guard let strongStatusChecker = self.statusChecker else {
                // Looks like the whole session is going down
                finish()
                return
            }
            
            if let prevOperation = dependencies.first(where: { $0 is FetchOperation }) as? FetchOperation {
                // If there's dependency that is another fetch operation, let's use its result without actual fetch
                result = prevOperation.result
                error = prevOperation.error
                finish()
                return
            }
            
            let powerAuth = strongStatusChecker.authSession.powerAuth
            fetchTask = powerAuth.fetchActivationStatus { [weak self] status, statusData, error in
                
                defer {
                    self?.finish()
                }
                
                guard let this = self, let strongStatusChecker = this.statusChecker else {
                    return
                }
                
                if let error = error {
                    this.error = LimeAuthError.wrap(error)
                } else if let status = status {
                    let fetchedData = (status, statusData)
                    strongStatusChecker.updateLastFetchedData(fetchedData)
                    this.result = fetchedData
                } else {
                    // TODO: build regular error object
                    D.error("ActivationStatusFetcher: Internal error: Unexpected result received from PowerAuth")
                }
            }
        }
        
        override func canceled() {
            fetchTask?.cancel()
        }
        
        private func finish() {
            markFinished {
                self.completion(self.result?.status, self.result?.data, self.error)
            }
        }
    }
}
