// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import MessageUI
import Shared
class ContactUsSettings: Setting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: .MenuKarmaFeedbackContactUs, attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }

    override func onClick(_ navigationController: UINavigationController?) {
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: NSLocalizedString("cannotsendemail", tableName: "Localizable", bundle: Strings.bundle, comment: ""), message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: .CancelString, style: .cancel, handler: { _ in
                
            }))
            navigationController?.present(alert, animated: true, completion: nil)
            return
        }
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = UIApplication.shared.delegate as! AppDelegate

        let userAgent = UIDevice.modelName + "(" +  UIDevice.current.systemVersion + ")"
        let appVersion = AppInfo.appVersion
        let subject = .MenuKarmaFeedbackContactUsEmailSubject + " " + userAgent + " - " + appVersion
        mailComposerVC.setToRecipients(["ios_app@mykarma.org"])
        mailComposerVC.setSubject(subject)

        navigationController?.present(mailComposerVC, animated: true, completion: nil)
    }
}

class RateAppSetting: Setting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: .MenuKarmaRateAppStore, attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }

    override func onClick(_ navigationController: UINavigationController?) {
        
        navigationController?.dismiss(animated: true) {
            if let url = URL(string: "https://apps.apple.com/app/id1596470046?action=write-review") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }

        
    }
}

class KarmaPrivacyPolicySetting: Setting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: .AppSettingsPrivacyPolicy, attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }

    override var url: URL? {
        if Locale.current.identifier.contains("fr") {
            return URL(string: "https://about.karmasearch.org/fr/legal")
        }
        return URL(string: "https://about.karmasearch.org/legal")
    }

    override func onClick(_ navigationController: UINavigationController?) {
        setUpAndPushSettingsContentViewController(navigationController, self.url)
    }
}
