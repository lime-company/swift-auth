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

import Foundation

class UIStopWatch {
    
    private let dispatchInterval: TimeInterval
    private var timer: Timer?
    private var started: Date!
    
    init(dispatchInterval: TimeInterval) {
        self.dispatchInterval = dispatchInterval
    }
    
    func start(callback: @escaping (_ elapsed: TimeInterval) -> Void) {
        started = Date()
        timer = Timer.scheduledTimer(withTimeInterval: dispatchInterval, repeats: true) { [weak self] timer in
            guard let this = self else {
                timer.invalidate()
                return
            }
            if let started = this.started {
                callback(Date().timeIntervalSince(started))
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        started = nil
    }
    
}
