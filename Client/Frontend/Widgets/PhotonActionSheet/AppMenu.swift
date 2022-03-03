/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import Account

extension PhotonActionSheetProtocol {

    //Returns a list of actions which is used to build a menu
    //OpenURL is a closure that can open a given URL in some view controller. It is up to the class using the menu to know how to open it
    func getLibraryActions(vcDelegate: PageOptionsVC) -> [PhotonActionSheetItem] {
        let bookmarks = PhotonActionSheetItem(title: .AppMenuBookmarks, iconString: "menu-panel-Bookmarks") { _, _ in
            let bvc = vcDelegate as? BrowserViewController
            bvc?.showLibrary(panel: .bookmarks)
        }
        let history = PhotonActionSheetItem(title: .AppMenuHistory, iconString: "menu-panel-History") { _, _ in
            let bvc = vcDelegate as? BrowserViewController
            bvc?.showLibrary(panel: .history)
        }
        let downloads = PhotonActionSheetItem(title: .AppMenuDownloads, iconString: "menu-panel-Downloads") { _, _ in
            let bvc = vcDelegate as? BrowserViewController
            bvc?.showLibrary(panel: .downloads)
        }

        return [bookmarks, history, downloads]
    }
    
    func getKarmaActions(vcDelegate: PageOptionsVC) -> [PhotonActionSheetItem] {
        let defaultbrowser = PhotonActionSheetItem(title: .MenuKarmaDefaultBrowser, iconString: "menu-panel-karma-default-browser", bold: true) { _, _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
        }
        var karmaBaseUrl = "https://about.karmasearch.org/"
        if Locale.current.identifier.contains("fr") {
            karmaBaseUrl.append(contentsOf: "fr/")
        }
        let bvc = vcDelegate as? BrowserViewController

        let mission = PhotonActionSheetItem(title: .MenuKarmaMission, iconString: "menu-panel-karma-globe") { _, _ in
            bvc?.showUrl(url: URL(string: karmaBaseUrl)!)
        }
        let how = PhotonActionSheetItem(title: .MenuKarmaHow, iconString: "menu-panel-karma-how") { _, _ in
            bvc?.showUrl(url: URL(string: karmaBaseUrl + "what")!)
        }
        let partners = PhotonActionSheetItem(title: .MenuKarmaPartners, iconString: "menu-panel-karma-partners") { _, _ in
            if Locale.current.identifier == "fr" {
                bvc?.showUrl(url: URL(string: "https://mykarma.notion.site/Our-Partners-a8cd5944d0e64872ac7f44c8b014a059")!)
            } else {
                bvc?.showUrl(url: URL(string: "https://mykarma.notion.site/Nos-partenaires-8c26dd107da341ccb0f0c7216cc2a6d5")!)
            }
        }
        let privacy = PhotonActionSheetItem(title: .MenuKarmaPrivacy, iconString: "menu-panel-karma-privacy") { _, _ in
            bvc?.showUrl(url: URL(string: karmaBaseUrl + "legal")!)
        }
        let legal = PhotonActionSheetItem(title: .MenuKarmaTermsOfService, iconString: "menu-panel-karma-legal") { _, _ in
            bvc?.showUrl(url: URL(string: karmaBaseUrl + "legal#imprint")!)
        }
        
        return [defaultbrowser, mission, how, partners, privacy, legal]
    }
    
    // Not part of AppMenu, but left for future use. 
    func getHomeAction(vcDelegate: Self.PageOptionsVC) -> [PhotonActionSheetItem] {
        guard let tab = self.tabManager.selectedTab else { return [] }
        
        let openHomePage = PhotonActionSheetItem(title: .AppMenuOpenHomePageTitleString, iconString: "menu-Home") { _, _ in
            let page = NewTabAccessors.getHomePage(self.profile.prefs)
            if page == .homePage, let homePageURL = HomeButtonHomePageAccessors.getHomePage(self.profile.prefs) {
                tab.loadRequest(PrivilegedRequest(url: homePageURL) as URLRequest)
            } else if let homePanelURL = page.url {
                tab.loadRequest(PrivilegedRequest(url: homePanelURL) as URLRequest)
            }
            TelemetryWrapper.recordEvent(category: .action, method: .tap, object: .home)
        }
        
        return [openHomePage]
    }

    func getSettingsAction(vcDelegate: Self.PageOptionsVC) -> [PhotonActionSheetItem] {

        let openSettings = PhotonActionSheetItem(title: .AppMenuSettingsTitleString, iconString: "menu-Settings") { _, _ in
            let settingsTableViewController = AppSettingsTableViewController()
            settingsTableViewController.profile = self.profile
            settingsTableViewController.tabManager = self.tabManager
            settingsTableViewController.settingsDelegate = vcDelegate
            
            let controller = ThemedNavigationController(rootViewController: settingsTableViewController)
            // On iPhone iOS13 the WKWebview crashes while presenting file picker if its not full screen. Ref #6232
            if UIDevice.current.userInterfaceIdiom == .phone {
                controller.modalPresentationStyle = .fullScreen
            }
            controller.presentingModalViewControllerDelegate = vcDelegate
            TelemetryWrapper.recordEvent(category: .action, method: .open, object: .settings)
            
            // Wait to present VC in an async dispatch queue to prevent a case where dismissal
            // of this popover on iPad seems to block the presentation of the modal VC.
            DispatchQueue.main.async {
                vcDelegate.present(controller, animated: true, completion: nil)
            }
        }
        return [openSettings]
    }
    
    func getOtherPanelActions(vcDelegate: PageOptionsVC) -> [PhotonActionSheetItem] {
        var items: [PhotonActionSheetItem] = []

        let feedback = PhotonActionSheetItem(title: .MenuKarmaFeedback, iconString: "menu-panel-karma-feedback") { _, _ in
            let settingsTableViewController = FeedbackViewController()
            settingsTableViewController.profile = self.profile
            settingsTableViewController.tabManager = self.tabManager
            settingsTableViewController.settingsDelegate = vcDelegate
            
            let controller = ThemedNavigationController(rootViewController: settingsTableViewController)
            // On iPhone iOS13 the WKWebview crashes while presenting file picker if its not full screen. Ref #6232
            if UIDevice.current.userInterfaceIdiom == .phone {
                controller.modalPresentationStyle = .fullScreen
            }
            controller.presentingModalViewControllerDelegate = vcDelegate
            TelemetryWrapper.recordEvent(category: .action, method: .open, object: .settings)
            
            // Wait to present VC in an async dispatch queue to prevent a case where dismissal
            // of this popover on iPad seems to block the presentation of the modal VC.
            DispatchQueue.main.async {
                vcDelegate.present(controller, animated: true, completion: nil)
            }
        }
        items.append(feedback)
        return items
    }

    func syncMenuButton(showFxA: @escaping (_ params: FxALaunchParams?, _ flowType: FxAPageType,_ referringPage: ReferringPage) -> Void) -> PhotonActionSheetItem? {
        //profile.getAccount()?.updateProfile()

        let action: ((PhotonActionSheetItem, UITableViewCell) -> Void) = { action,_ in
            let fxaParams = FxALaunchParams(query: ["entrypoint": "browsermenu"])
            showFxA(fxaParams, .emailLoginFlow, .appMenu)
            TelemetryWrapper.recordEvent(category: .action, method: .tap, object: .signIntoSync)
        }

        let rustAccount = RustFirefoxAccounts.shared
        let needsReauth = rustAccount.accountNeedsReauth()

        guard let userProfile = rustAccount.userProfile else {
            return PhotonActionSheetItem(title: .AppMenuBackUpAndSyncData, iconString: "menu-sync", handler: action)
        }
        let title: String = {
            if rustAccount.accountNeedsReauth() {
                return .FxAAccountVerifyPassword
            }
            return userProfile.displayName ?? userProfile.email
        }()

        let iconString = needsReauth ? "menu-warning" : "placeholder-avatar"

        var iconURL: URL? = nil
        if let str = rustAccount.userProfile?.avatarUrl, let url = URL(string: str) {
            iconURL = url
        }
        let iconType: PhotonActionSheetIconType = needsReauth ? .Image : .URL
        let iconTint: UIColor? = needsReauth ? UIColor.Photon.Yellow60 : nil
        let syncOption = PhotonActionSheetItem(title: title, iconString: iconString, iconURL: iconURL, iconType: iconType, iconTint: iconTint, handler: action)
        return syncOption
    }
}
