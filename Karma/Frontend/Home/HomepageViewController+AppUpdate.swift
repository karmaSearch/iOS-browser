// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared

extension HomepageViewController: AppUpdateAlertDelegate {
    func showAppUpdateMessage(urlAppStore: String) {
        let alertController = UIAlertController(title: .AppUpdateTitle, message: .AppUpdateMessage, preferredStyle: .alert)
        
        let updateNowAction = UIAlertAction(title: .AppUpdateNow, style: .default) { _ in
            UIApplication.shared.open(URL(string: urlAppStore)!)
        }
      
        alertController.addAction(updateNowAction)
        alertController.addAction(UIAlertAction(title: .AppUpdateLater, style: .cancel))
       present(alertController, animated: true)
    }
    
}
