//
//  FeedbackViewController.swift
//  Client
//
//  Created by Lilla on 24/11/2021.
//  Copyright © 2021 Mozilla. All rights reserved.
//

import Foundation

class FeedbackViewController: SettingsTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = .MenuKarmaFeedback
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: .AppSettingsDone,
            style: .done,
            target: navigationController, action: #selector((navigationController as! ThemedNavigationController).done))
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "FeedbackViewController.navigationItem.leftBarButtonItem"

        tableView.accessibilityIdentifier = "FeedbackViewController.tableView"

    }
    
    override func generateSettings() -> [SettingSection] {

        return [
            SettingSection(children: [
                SendFeedbackSetting(delegate: self.settingsDelegate),
                AppStoreReviewSetting(),
                ContactUsSettings()
            ])]
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = super.tableView(tableView, viewForHeaderInSection: section) as! ThemedTableSectionHeaderFooterView
        return headerView
    }
}
