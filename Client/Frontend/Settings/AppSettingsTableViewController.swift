// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import UIKit
import Shared

enum AppSettingsDeeplinkOption {
    case contentBlocker
    case customizeHomepage
    case customizeTabs
    case customizeToolbar
    case customizeTopSites
    case wallpaper
}

/// App Settings Screen (triggered by tapping the 'Gear' in the Tab Tray Controller)
class AppSettingsTableViewController: SettingsTableViewController, FeatureFlaggable {

    // MARK: - Properties
    var deeplinkTo: AppSettingsDeeplinkOption?
    private var themeManager: ThemeManager

    // MARK: - Initializers
    init(with profile: Profile,
         and tabManager: TabManager,
         delegate: SettingsDelegate?,
         deeplinkingTo destination: AppSettingsDeeplinkOption? = nil,
         themeManager: ThemeManager = AppContainer.shared.resolve()) {
        self.deeplinkTo = destination
        self.themeManager = themeManager

        super.init()
        self.profile = profile
        self.tabManager = tabManager
        self.settingsDelegate = delegate
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = String.AppSettingsTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: .AppSettingsDone,
            style: .done,
            target: navigationController,
            action: #selector((navigationController as! ThemedNavigationController).done))
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "AppSettingsTableViewController.navigationItem.leftBarButtonItem"

        tableView.accessibilityIdentifier = "AppSettingsTableViewController.tableView"

        // Refresh the user's FxA profile upon viewing settings. This will update their avatar,
        // display name, etc.
        //// profile.rustAccount.refreshProfile()

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

        case .customizeTabs:
            viewController = TabsSettingsViewController()

        case .customizeToolbar:
            let viewModel = SearchBarSettingsViewModel(prefs: profile.prefs)
            viewController = SearchBarSettingsViewController(viewModel: viewModel)

        case .wallpaper:
            let wallpaperManager = WallpaperManager()
            if wallpaperManager.canSettingsBeShown {
                let viewModel = WallpaperSettingsViewModel(wallpaperManager: wallpaperManager, tabManager: tabManager)
                let wallpaperVC = WallpaperSettingsViewController(viewModel: viewModel)
                navigationController?.pushViewController(wallpaperVC, animated: true)
            }
            return

        case .customizeTopSites:
            viewController = TopSitesSettingsViewController()
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

        let nightModeTitle: String = nightModeEnabled ? String.AppMenu.AppMenuTurnOffNightMode : String.AppMenu.AppMenuTurnOnNightMode
        let imageModeTitle: String = String.Settings.Toggle.NoImageMode

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
                                self.themeManager.changeCurrentTheme(.dark)
                                NightModeHelper.setEnabledDarkTheme(self.profile.prefs, darkTheme: true)
                            }
                            // If we've disabled night mode and dark theme was activated by it then disable dark theme
                            if !NightModeHelper.isActivated(self.profile.prefs), NightModeHelper.hasEnabledDarkTheme(self.profile.prefs), LegacyThemeManager.instance.currentName == .dark {
                                self.themeManager.changeCurrentTheme(.light)
                                NightModeHelper.setEnabledDarkTheme(self.profile.prefs, darkTheme: false)
                            }
                        }),
            SiriPageSetting(settings: self),
            BoolSetting(prefs: prefs, prefKey: PrefsKeys.KeyNoImageModeStatus, defaultValue: false, titleText: imageModeTitle, statusText: .AppMenuNoImageStatus, settingDidChange: { isOn in
                self.tabManager.tabs.forEach { $0.noImageMode = isOn }
            }),
            BoolSetting(prefs: prefs, prefKey: PrefsKeys.KeyBlockPopups, defaultValue: true,
                        titleText: .AppSettingsBlockPopups),
            NoImageModeSetting(settings: self)

           ]

        if SearchBarSettingsViewModel.isEnabled {
            generalSettings.insert(SearchBarSetting(settings: self), at: 5)
        }

        let tabTrayGroupsAreBuildActive = featureFlags.isFeatureEnabled(.tabTrayGroups, checking: .buildOnly)
        let inactiveTabsAreBuildActive = featureFlags.isFeatureEnabled(.inactiveTabs, checking: .buildOnly)
        if tabTrayGroupsAreBuildActive || inactiveTabsAreBuildActive {
            generalSettings.insert(TabsSetting(), at: 3)
        }

        let accountChinaSyncSetting: [Setting]
        if !AppInfo.isChinaEdition {
            accountChinaSyncSetting = []
        } else {
            accountChinaSyncSetting = [
                // Show China sync service setting:
                ChinaSyncServiceSetting(settings: self)
            ]
        }
        // There is nothing to show in the Customize section if we don't include the compact tab layout
        // setting on iPad. When more options are added that work on both device types, this logic can
        // be changed.

        generalSettings += [
            BoolSetting(
                prefs: prefs,
                prefKey: "showClipboardBar",
                defaultValue: false,
                titleText: .SettingsOfferClipboardBarTitle,
                statusText: .SettingsOfferClipboardBarStatus),
            BoolSetting(
                prefs: prefs,
                prefKey: PrefsKeys.ContextMenuShowLinkPreviews,
                defaultValue: true,
                titleText: .SettingsShowLinkPreviewsTitle,
                statusText: .SettingsShowLinkPreviewsStatus)
        ]

        if #available(iOS 14.0, *) {
            settings += [
                SettingSection(footerTitle: NSAttributedString(string: String.FirefoxHomepage.HomeTabBanner.EvergreenMessage.HomeTabBannerDescription),
                               children: [DefaultBrowserSetting()])
            ]
        }

        let accountSectionTitle = NSAttributedString(string: .FxAFirefoxAccount)

        let footerText = !profile.hasAccount() ? NSAttributedString(string: .Settings.Sync.ButtonDescription) : nil
        settings += [
            SettingSection(title: accountSectionTitle, footerTitle: footerText, children: [
                // Without a Firefox Account:
                ConnectSetting(settings: self),
                AdvancedAccountSetting(settings: self),
                // With a Firefox Account:
                AccountStatusSetting(settings: self),
                SyncNowSetting(settings: self)
            ] + accountChinaSyncSetting )]

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
                AppStoreReviewSetting(),
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
