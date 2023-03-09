// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared

protocol AppUpdateAlertDelegate: AnyObject {
    func showAppUpdateMessage(urlAppStore: String)
}

class AppUpdateViewModel {
    let appUpdateManager: AppUpdateManager
    weak var delegate: AppUpdateAlertDelegate?
    
    init(appUpdateManager: AppUpdateManager) {
        self.appUpdateManager = appUpdateManager
        
        self.checkUpdate()
    }
    
    
    func canCheckUpdate() -> Bool {
        let today = Date()
        let oneWeek = 7 * 24 * 60 * 60
        
        guard let lastCheckDate = UserDefaults.standard.value(forKey: "CHECK_UPDATE_DATE") as? Date else { return true }

        return today >= lastCheckDate.addingTimeInterval(TimeInterval(oneWeek))
    }
    
    func checkUpdate() {
        guard canCheckUpdate() else { return }
        Task {
            let updateStatus = await appUpdateManager.checkUpdateStatus()
            UserDefaults.standard.set(Date(), forKey: "CHECK_UPDATE_DATE")

            if case .noUpdate = updateStatus {
                return
            }
            DispatchQueue.main.async {
                self.delegate?.showAppUpdateMessage(urlAppStore: "https://itunes.apple.com/app/"+AppInfo.appStoreId)
            }

        }
    }
}
