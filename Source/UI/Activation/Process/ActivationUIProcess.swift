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

public protocol ActivationUIProvider {
    
    func instantiateInitialScene() -> BeginActivationViewController
    func instantiateConfirmScene() -> ConfirmActivationViewController
    func instantiateScanCodeScene() -> ScanActivationCodeViewController
    func instantiateEnterCodeScene() -> EnterActivationCodeViewController
    func instantiateNavigationController(with rootController: UIViewController) -> UINavigationController?
    
    var uiDataProvider: ActivationUIDataProvider { get }
}

public protocol ActivationUIDataProvider {
    
    var uiCommonStrings: Activation.UIData.CommonStrings { get }
    var uiCommonStyle: Activation.UIData.CommonStyle { get }
    
    var uiDataForBeginActivation: BeginActivation.UIData { get }
    var uiDataForNoCameraAccess: NoCameraAccess.UIData { get }
    var uiDataForEnterActivationCode: EnterActivationCode.UIData { get }
    var uiDataForScanActivationCode: ScanActivationCode.UIData { get }
    var uiDataForKeysExchange: KeysExchange.UIData { get }
    var uiDataForEnableBiometry: EnableBiometry.UIData { get }
    var uiDataForConfirmActivation: ConfirmActivation.UIData { get }
    var uiDataForErrorActivation: ErrorActivation.UIData { get }
    
}

public class ActivationUIProcess {
    
    public let session: LimeAuthSession
    public let uiDataProvider: ActivationUIDataProvider
    public let credentialsProvider: LimeAuthCredentialsProvider
    public private(set) var activationData: Activation.Data
    
    public internal(set) var cancelShouldRouteToBegin = false
    public internal(set) weak var initialController: UIViewController?
    public internal(set) weak var finalController: UIViewController?
    
    internal var completion: ((Activation.Data)->Void)?
    
    public init(session: LimeAuthSession, uiDataProvider: ActivationUIDataProvider, credentialsProvider: LimeAuthCredentialsProvider) {
        self.session = session
        self.uiDataProvider = uiDataProvider
        self.activationData = Activation.Data()
        self.credentialsProvider = credentialsProvider
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
    
    public func failActivation(controller: UIViewController?, with error: LimeAuthError? = nil) {
        // activation error
        finalController = controller
        activationData.result = .failure
        if error != nil {
            activationData.failureReason = error
        }
        presentResult()
    }
    
    public func storeFailureReason(error: LimeAuthError) {
        activationData.failureReason = error
    }
    
    public func clearActivationData() {
        // Restart activation process
        activationData = Activation.Data()
        if session.hasPendingActivation || session.hasValidActivation {
            session.removeActivationLocal()
        }
    }
    
    private func presentResult() {
        if activationData.result != .success && (session.hasPendingActivation || session.hasValidActivation) {
            // Make sure that session's in initial state
            session.removeActivationLocal()
        }
        completion?(activationData)
    }
}


public protocol ActivationUIProcessRouter {
    var activationProcess: ActivationUIProcess! { get set }
}

public protocol ActivationUIProcessController {
    func connect(activationProcess process: ActivationUIProcess)
}
