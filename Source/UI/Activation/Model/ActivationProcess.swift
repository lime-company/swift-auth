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

import UIKit

public class ActivationProcess {
    
    public private(set) var session: LimeAuthSession
    public private(set) var uiData: Activation.UIData
    public private(set) var activationData: Activation.Data
    
    public private(set) weak var initialController: UIViewController?
    public private(set) weak var finalController: UIViewController?
    
    public init(session: LimeAuthSession, uiData: Activation.UIData) {
        self.session = session
        self.uiData = uiData
        self.activationData = Activation.Data()
    }
    
    // MARK: - Activation control
    
    public func completeActivation(controller: UIViewController?) {
        // success
        finalController = controller
        activationData.result = .success
        presentResult()
    }
    
    public func cancelActivation(controller: UIViewController?) {
        // user did cancel
        finalController = controller
        activationData.result = .cancel
        presentResult()
    }
    
    public func completeActivation(controller: UIViewController?, with error: Error) {
        // activation error
        finalController = controller
        activationData.result = .failure
        activationData.failureReason = error
        presentResult()
    }
    
    private func presentResult() {
        if activationData.result != .success && (session.hasPendingActivation || session.hasValidActivation) {
            // Make sure that session's in initial state
            session.removeActivationLocal()
        }
    }
    
    
    // MARK: - UI configuration getters
    
    public var uiCommonStrings: Activation.UIData.CommonStrings {
        return uiData.commonStrings
    }
    
    public var uiDataForBeginActivation: BeginActivation.UIData {
        return uiData.beginActivation
    }
    
    public var uiDataForNoCameraAccess: NoCameraAccess.UIData {
        return uiData.noCameraAccess
    }
    
    public var uiDataForEnterActivationCode: EnterActivationCode.UIData {
        return uiData.enterActivationCode
    }
    
    public var uiDataForScanActivationCode: ScanActivationCode.UIData {
        return uiData.scanActivationCode
    }
    
    public var uiDataForKeysExchange: KeysExchange.UIData {
        return uiData.keysExchange
    }
    
    public var uiDataForEnableBiometry: EnableBiometry.UIData {
        return uiData.enableBiometry
    }
    
    public var uiDataForConfirmActivation: ConfirmActivation.UIData {
        return uiData.confirmActivation
    }
    
    public var uiDataForSuccessActivation: SuccessActivation.UIData {
        return uiData.successActivation
    }
    
    public var uiDataForErrorActivation: ErrorActivation.UIData {
        return uiData.errorActivation
    }
}


public protocol ActivationProcessRouter {
    var activationProcess: ActivationProcess! { get set }
}

public protocol ActivationProcessController {
    func connect(activationProcess process: ActivationProcess)
}
