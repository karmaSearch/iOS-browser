// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

class AboutKarmaViewController: SettingsTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = .MenuKarmaAbout
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: .AppSettingsDone,
            style: .done,
            target: navigationController, action: #selector((navigationController as! ThemedNavigationController).done))
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "AboutKarmaViewController.navigationItem.leftBarButtonItem"

        tableView.accessibilityIdentifier = "AboutKarmaViewController.tableView"

    }
    
    override func generateSettings() -> [SettingSection] {

        return [
            SettingSection(children: [
                OurMissionSetting(),
                HowSetting(),
                PartnersSetting(),
                PrivacySetting(),
                TermsOfServicesSetting(),
                SendFeedbackSetting(),
                LicenseAndAcknowledgementsSetting()
            ])]
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = super.tableView(tableView, viewForHeaderInSection: section) as! ThemedTableSectionHeaderFooterView
        return headerView
    }
}
