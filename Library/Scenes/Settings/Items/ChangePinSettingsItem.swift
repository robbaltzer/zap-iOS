//
//  ZapShared
//
//  Created by Otto Suess on 18.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning

final class ChangePinSettingsItem: SettingsItem {
    let title = L10n.Scene.Settings.Item.changePin
    
    private weak var settingsDelegate: SettingsDelegate?
    private weak var setupPinViewController: SetupPinViewController?
    
    init(settingsDelegate: SettingsDelegate) {
        self.settingsDelegate = settingsDelegate
    }
    
    func didSelectItem(from fromViewController: UIViewController) {
        guard let authenticationViewModel = settingsDelegate?.authenticationViewModel else { return }
        ModalPinViewController.authenticate(authenticationViewModel: authenticationViewModel) { [weak self] result in
            switch result {
            case .success:
                let viewModel = SetupPinViewModel(authenticationViewModel: authenticationViewModel)
                let setupPinViewController = SetupPinViewController.instantiate(setupPinViewModel: viewModel) { [weak self] in
                    self?.setupPinViewController?.dismiss(animated: true, completion: nil)
                }
                self?.setupPinViewController = setupPinViewController
                fromViewController.present(setupPinViewController, animated: true, completion: nil)
            case .failure:
                return
            }
        }
    }
}
