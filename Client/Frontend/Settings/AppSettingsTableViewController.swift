/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared

enum AppSettingsDeeplinkOption {
    case contentBlocker
    case customizeHomepage
}

/// App Settings Screen (triggered by tapping the 'Gear' in the Tab Tray Controller)
class AppSettingsTableViewController: SettingsTableViewController, FeatureFlagsProtocol {
    var deeplinkTo: AppSettingsDeeplinkOption?

    override func viewDidLoad() {
        super.viewDidLoad()

        let variables = Experiments.shared.getVariables(featureId: .nimbusValidation)
        let title = variables.getText("settings-title") ?? .AppSettingsTitle
        let suffix = variables.getString("settings-title-punctuation") ?? ""

        navigationItem.title = "\(title)\(suffix)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: .AppSettingsDone,
            style: .done,
            target: navigationController, action: #selector((navigationController as! ThemedNavigationController).done))
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "AppSettingsTableViewController.navigationItem.leftBarButtonItem"

        tableView.accessibilityIdentifier = "AppSettingsTableViewController.tableView"

        // Refresh the user's FxA profile upon viewing settings. This will update their avatar,
        // display name, etc.
        ////profile.rustAccount.refreshProfile()

        checkForDeeplinkSetting()
    }

    private func checkForDeeplinkSetting() {
        guard let deeplink = deeplinkTo else { return }
        var viewController: SettingsTableViewController

        switch deeplink {
        case .contentBlocker:
            viewController = ContentBlockerSettingViewController(prefs: profile.prefs)
            viewController.tabManager = tabManager

        case .customizeHomepage:
            viewController = HomePageSettingViewController(prefs: profile.prefs)
        }

        viewController.profile = profile
        navigationController?.pushViewController(viewController, animated: false)
        // Add a done button from this view
        viewController.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem
    }

    override func generateSettings() -> [SettingSection] {
        var settings = [SettingSection]()

        let prefs = profile.prefs
        
        let nightModeEnabled = NightModeHelper.isActivated(profile.prefs)
        let noImageEnabled = NoImageModeHelper.isActivated(profile.prefs)

        let nightModeTitle: String = nightModeEnabled ? .AppMenuTurnOffNightMode : .AppMenuTurnOnNightMode
        let imageModeTitle: String = noImageEnabled ? .AppMenuShowImageMode : .AppMenuNoImageMode

        var generalSettings: [Setting] = [
            OpenWithSetting(settings: self),
            ThemeSetting(settings: self),
            BoolSetting(prefs: prefs, prefKey: NightModePrefsKey.NightModeStatus, defaultValue: false,
                        titleText: nightModeTitle, statusText: .AppMenuTurnOffNightModeStatus, settingDidChange: { isOn in
                            NightModeHelper.setNightMode(self.profile.prefs, tabManager: self.tabManager, enabled: isOn)
                            if nightModeEnabled {
                                TelemetryWrapper.recordEvent(category: .action, method: .tap, object: .nightModeDisabled)
                            } else {
                                TelemetryWrapper.recordEvent(category: .action, method: .tap, object: .nightModeDisabled)
                            }

                            // If we've enabled night mode and the theme is normal, enable dark theme
                            if NightModeHelper.isActivated(self.profile.prefs), LegacyThemeManager.instance.currentName == .normal {
                                LegacyThemeManager.instance.current = DarkTheme()
                                NightModeHelper.setEnabledDarkTheme(self.profile.prefs, darkTheme: true)
                            }
                            // If we've disabled night mode and dark theme was activated by it then disable dark theme
                            if !NightModeHelper.isActivated(self.profile.prefs), NightModeHelper.hasEnabledDarkTheme(self.profile.prefs), LegacyThemeManager.instance.currentName == .dark {
                                LegacyThemeManager.instance.current = NormalTheme()
                                NightModeHelper.setEnabledDarkTheme(self.profile.prefs, darkTheme: false)
                            }
                        }),
            SiriPageSetting(settings: self),
            BoolSetting(prefs: prefs, prefKey: PrefsKeys.KeyNoImageModeStatus, defaultValue: false, titleText: imageModeTitle, statusText: .AppMenuNoImageStatus, settingDidChange: { isOn in
                self.tabManager.tabs.forEach { $0.noImageMode = isOn }
            }),
            BoolSetting(prefs: prefs, prefKey: PrefsKeys.KeyBlockPopups, defaultValue: true,
                        titleText: .AppSettingsBlockPopups),
           ]

        // There is nothing to show in the Customize section if we don't include the compact tab layout
        // setting on iPad. When more options are added that work on both device types, this logic can
        // be changed.

        generalSettings += [
            BoolSetting(prefs: prefs, prefKey: "showClipboardBar", defaultValue: false,
                        titleText: .SettingsOfferClipboardBarTitle,
                        statusText: .SettingsOfferClipboardBarStatus),
            BoolSetting(prefs: prefs, prefKey: PrefsKeys.ContextMenuShowLinkPreviews, defaultValue: true,
                        titleText: .SettingsShowLinkPreviewsTitle,
                        statusText: .SettingsShowLinkPreviewsStatus)
        ]

        if #available(iOS 14.0, *) {
            settings += [
                SettingSection(footerTitle: NSAttributedString(string: String.DefaultBrowserCardDescription), children: [DefaultBrowserSetting()])
            ]
        }


        settings += [ SettingSection(title: NSAttributedString(string: .SettingsGeneralSectionTitle), children: generalSettings)]

        var privacySettings = [Setting]()
        privacySettings.append(LoginsSetting(settings: self, delegate: settingsDelegate))

        privacySettings.append(ClearPrivateDataSetting(settings: self))

        privacySettings += [
            BoolSetting(prefs: prefs,
                prefKey: "settings.closePrivateTabs",
                defaultValue: false,
                titleText: .AppSettingsClosePrivateTabsTitle,
                statusText: .AppSettingsClosePrivateTabsDescription)
        ]

        privacySettings.append(ContentBlockerSetting(settings: self))

        privacySettings += [
            PrivacyPolicySetting()
        ]

        settings += [
            SettingSection(title: NSAttributedString(string: .AppSettingsPrivacyTitle), children: privacySettings),
            SettingSection(title: NSAttributedString(string: .AppSettingsSupport), children: [
                ShowIntroductionSetting(settings: self),
                ContactUsSettings(),
            ]),
            SettingSection(title: NSAttributedString(string: .AppSettingsAbout), children: [
                VersionSetting(settings: self),
                LicenseAndAcknowledgementsSetting(),
            ])]

        return settings
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = super.tableView(tableView, viewForHeaderInSection: section) as! ThemedTableSectionHeaderFooterView
        return headerView
    }
}
