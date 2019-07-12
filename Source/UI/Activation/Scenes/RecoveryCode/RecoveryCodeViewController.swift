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

import UIKit
import PowerAuth2

public class RecoveryCodeViewController: LimeAuthUIBaseViewController, ActivationUIProcessController {
    
    private var router: (RecoveryCodeRoutingLogic & ActivationUIProcessRouter)!
    private var uiDataProvider: ActivationUIDataProvider!
    private var uiRecoveryProvider: RecoveryUIProvider!
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Lets reuse the RecoveryViewController to display data
        
        let vc = uiRecoveryProvider.instantiateRecoveryController()
        guard let recoveryData = router.activationProcess.activationData.createActivationResult?.activationRecovery else {
            D.fatalError("recovery data expected here")
        }
        
        let rData = LimeAuthRecoveryData(activationCode: recoveryData.recoveryCode, puk: recoveryData.puk)
        let isReactivation = router.activationProcess.activationData.puk != nil
        
        vc.setup(withData: rData, uiProvider: uiRecoveryProvider, context: isReactivation ? .reactivation : .activation) { [weak self] _ in
            self?.router.routeToSuccess()
        }
        
        // embed the recovery code controller into this one
        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            vc.view.topAnchor.constraint(equalTo: view.topAnchor),
            vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            vc.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            vc.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    private func setup() {
        let router = RecoveryCodeRouter()
        router.viewController = self
        self.router = router
    }
    
    // MARK: - Routing
    
    open func connect(activationProcess process: ActivationUIProcess) {
        router?.activationProcess = process
        uiDataProvider = process.uiDataProvider
        uiRecoveryProvider = process.uiRecoveryProvider
    }
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router?.prepare(for: segue, sender: sender)
    }
    
    // MARK: Actions
    
    func continueAction() {
        router?.routeToSuccess()
    }
}
