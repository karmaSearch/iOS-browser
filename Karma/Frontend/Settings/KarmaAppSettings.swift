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

class KarmaPrivacyPolicySetting: Setting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: .AppSettingsPrivacyPolicy, attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }

    override var url: URL? {
        if Locale.current.identifier.contains("fr") {
            return URL(string: "https://info.karmasearch.org/fr/legal")
        }
        return URL(string: "https://info.karmasearch.org/legal")
    }

    override func onClick(_ navigationController: UINavigationController?) {
        setUpAndPushSettingsContentViewController(navigationController, self.url)
    }
}


class OurMissionSetting: Setting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: .MenuKarmaMission, attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }

    override var url: URL? {
        if Locale.current.identifier.contains("fr") {
            return URL(string: "https://info.karmasearch.org/fr/mission")
        }
        return URL(string: "https://info.karmasearch.org")
    }

    override func onClick(_ navigationController: UINavigationController?) {
        setUpAndPushSettingsContentViewController(navigationController, self.url)
    }
}

class HowSetting: Setting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: .MenuKarmaHow, attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }

    override var url: URL? {
        if Locale.current.identifier.contains("fr") {
            return URL(string: "https://info.karmasearch.org/fr/what")
        }
        return URL(string: "https://info.karmasearch.org/what")
    }

    override func onClick(_ navigationController: UINavigationController?) {
        setUpAndPushSettingsContentViewController(navigationController, self.url)
    }
}

class PartnersSetting: Setting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: .MenuKarmaPartners, attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }

    override var url: URL? {
        if Locale.current.identifier.contains("fr") {
            return URL(string: "https://info.karmasearch.org/fr/partners")
        }
        return URL(string: "https://info.karmasearch.org/partners")
    }

    override func onClick(_ navigationController: UINavigationController?) {
        setUpAndPushSettingsContentViewController(navigationController, self.url)
    }
}

class PrivacySetting: Setting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: .MenuKarmaPrivacy, attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }

    override var url: URL? {
        if Locale.current.identifier.contains("fr") {
            return URL(string: "https://mykarma.notion.site/Protection-de-la-vie-priv-e-chez-KARMA-bd2ecd084fad446d866073ec28b20c54")
        }
        return URL(string: "https://mykarma.notion.site/Privacy-policy-3b80157379e349acb1ac529daa3b70a3")
    }

    override func onClick(_ navigationController: UINavigationController?) {
        setUpAndPushSettingsContentViewController(navigationController, self.url)
    }
}

class TermsOfServicesSetting: Setting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: .MenuKarmaTermsOfService, attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }

    override var url: URL? {
        if Locale.current.identifier.contains("fr") {
            return URL(string: "https://mykarma.notion.site/Conditions-d-utilisation-c5f461f440b3475cbac000dc10d8527e")
        }
        return URL(string: "https://mykarma.notion.site/Terms-of-service-e73514e7789b4f98b8883f88dbd11b32")
    }

    override func onClick(_ navigationController: UINavigationController?) {
        setUpAndPushSettingsContentViewController(navigationController, self.url)
    }
}

class FAQSetting: Setting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: .AppMenu.Help, attributes: [NSAttributedString.Key.foregroundColor: UIColor.theme.tableView.rowText])
    }

    override var url: URL? {
        if Locale.current.identifier.contains("fr") {
            return URL(string: "https://mykarma.notion.site/FAQ-3f414d5137ad429a8c5812dedfb821e2")
        } else {
            return URL(string: "https://mykarma.notion.site/FAQ-cb51ac0956484daf8ede50028a3a89c7")
        }
    }

    override func onClick(_ navigationController: UINavigationController?) {
        setUpAndPushSettingsContentViewController(navigationController, self.url)
    }
}

