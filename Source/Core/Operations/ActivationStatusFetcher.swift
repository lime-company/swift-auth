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
import LimeCore

internal class ActivationStatusFetcher {
    
    private unowned var authSession: LimeAuthSession
    
    private var lock = Lock()
    
    init(session: LimeAuthSession) {
        self.authSession = session
    }
    
    typealias FetchStatusCompletion = (PA2ActivationStatus?, [AnyHashable : Any]?, Error?) -> Void
    typealias FetchStatusData = (status: PA2ActivationStatus, data: [AnyHashable: Any]?)
    
    
    
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
        let (fireNotification, removeLocal) = lock.synchronized { ()->(Bool, Bool) in
            // Determine whether the state value has been changed
            var fireNotification: Bool
            if let oldState = self._lastFetchedData?.status.state {
                fireNotification = oldState != data.status.state
            } else {
                fireNotification = false
            }
            // And keep new data in this synchronized block
            let removeLocal = data.status.state == .removed
            if !removeLocal {
                self._lastFetchedData = data
            } else {
                self._lastFetchedData = nil
                fireNotification = true
            }
            self.shouldUpdate = false
            return (fireNotification, removeLocal)
        }
        // At first, remove local activation, if required.
        if removeLocal {
            let session = authSession
            DispatchQueue.main.async {
                session.removeActivationLocal()
            }
        }
        // Then fire notification about the status change
        if fireNotification {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: LimeAuthSession.didChangeActivationStatus, object: nil)
            }
        }
    }
    

    /// Actual operation performing data load
    private weak var realFetchOperation: RealFetch?

    /// Updates activation status
    internal func updateActivationStatus(completion: @escaping FetchStatusCompletion) -> Operation {
        
        let operation = authSession.buildBlockOperation(execute: { (op) -> RealFetch? in
            // Operation execution
            if let realFetch = self.realFetchOperation {
                // Fetch operation already exists, just add "this" operation
                // to weak sub operations array
                realFetch.subOperations.append(op)
                return realFetch
            }
            let session = self.authSession
            
            let realFetch = RealFetch(statusChecker: self)
            // Fetch completes its operation on concurrentQueue's thread
            realFetch.assignCompletionDispatchQueue(session.concurrentQueue.underlyingQueue)
            // Add "this" operation to weak sub operations array
            realFetch.subOperations.append(op)
            // Add "Fetch" to concurrent operations and return its
            session.concurrentQueue.addOperation(realFetch)
            return realFetch
            
        }, completion: { (op, result: FetchStatusData?, error) in
            // in completion dispatch queue (typically main)
            completion(result?.status, result?.data, error)
        })
        return authSession.addOperationToQueue(operation, serialized: false)
    }
    
    
    /// Helper operation class retrieving status from the server
    private class RealFetch: AsyncOperation<FetchStatusData, PA2OperationTask> {
        
        weak var statusChecker: ActivationStatusFetcher?
        
        typealias SubOperation = AsyncOperation<FetchStatusData, RealFetch>
        
        var subOperations: [WeakObject<SubOperation>] = []
        
        init(statusChecker: ActivationStatusFetcher) {
            self.statusChecker = statusChecker
        }
        
        override func onExecute() -> PA2OperationTask? {
            guard let strongStatusChecker = self.statusChecker else {
                // Looks like the whole session is going down
                self.finish(result: nil, error: nil)
                return nil
            }
            let powerAuth = strongStatusChecker.authSession.powerAuth
            return powerAuth.fetchActivationStatus { [weak self] (status, statusData, error) in
                // Reset realFetchOperation immediately
                guard let `self` = self, let strongStatusChecker = self.statusChecker else {
                    return
                }
                strongStatusChecker.realFetchOperation = nil
                if let error = error {
                    self.finish(error: error)
                } else if let status = status {
                    let fetchedData = (status, statusData)
                    strongStatusChecker.updateLastFetchedData(fetchedData)
                    self.finish(result: fetchedData)
                } else {
                    // TODO: build regular error object
                    D.print("ActivationStatusFetcher: Internal error: Unexpected result received from PowerAuth")
                }
            }
        }
        
        override func onComplete(result: ActivationStatusFetcher.FetchStatusData?, error: Error?) {
            // in concurrent queue, cleanup everything
            subOperations.allStrongReferences.forEach { (operation) in
                operation.finish(result: result, error: error)
            }
            subOperations.removeAll()
        }
        
        override func onCancel(_ cancellable: PA2OperationTask) {
            // TODO: Use this cancel in case that object is going to be destroyed
            cancellable.cancel()
            
            subOperations.allStrongReferences.forEach { (operation) in
                operation.cancel()
            }
            subOperations.removeAll()
        }
    }

    
    
}
