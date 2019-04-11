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
import PowerAuth2

protocol RecoveryPresenter: class {
    func presentState(_ state: RecoveryViewModel.DisplayState)
}

class RecoveryViewModel {
    
    enum DisplayState {
        case loading
        case data(_ data: LimeAuthRecoveryData)
        case error(_ error: LimeAuthError?)
    }
    
    private enum DisplayMode {
        case simple(_ data: LimeAuthRecoveryData)
        case withLoading(_ session: LimeAuthSession, _ auth: PowerAuthAuthentication)
    }
    
    weak var presenter: RecoveryPresenter?
    
    private let mode: DisplayMode
    private var isRecoveryLoading = false
    
    init(withData data: LimeAuthRecoveryData) {
        mode = .simple(data)
    }
    
    init(withAuthentication auth: PowerAuthAuthentication, andSession session: LimeAuthSession) {
        mode = .withLoading(session, auth)
    }
    
    func start() {
        switch mode {
        case .simple(let data):
            presenter?.presentState(.data(data))
        case .withLoading:
            getRecoveryCode()
        }
    }
    
    func getRecoveryCode() {
        
        guard isRecoveryLoading == false, case .withLoading(let session, let auth) = mode else {
            return
        }
        
        isRecoveryLoading = true
        presenter?.presentState(.loading)
        
        session.getActivationRecovery(authentication: auth) { [weak self] data, error in
            DispatchQueue.main.async {
                if let data = data {
                    self?.presenter?.presentState(.data(data))
                } else {
                    self?.presenter?.presentState(.error(error))
                }
                self?.isRecoveryLoading = false
            }
        }
    }
    
}
