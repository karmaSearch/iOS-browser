// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Shared
import Storage
import Sync
import XCGLogger
import UserNotifications
import Account
import MozillaAppServices

private let log = Logger.browserLogger

/**
 * This exists because the Sync code is extension-safe, and thus doesn't get
 * direct access to UIApplication.sharedApplication, which it would need to display a notification.
 * This will also likely be the extension point for wipes, resets, and getting access to data sources during a sync.
 */
enum SentTabAction: String {
    case view = "TabSendViewAction"

    static let TabSendURLKey = "TabSendURL"
    static let TabSendTitleKey = "TabSendTitle"
    static let TabSendCategory = "TabSendCategory"

    static func registerActions() {
        let viewAction = UNNotificationAction(identifier: SentTabAction.view.rawValue, title: .SentTabViewActionTitle, options: .foreground)

        // Register ourselves to handle the notification category set by NotificationService for APNS notifications
        let sentTabCategory = UNNotificationCategory(
            identifier: "org.mozilla.ios.SentTab.placeholder",
            actions: [viewAction],
            intentIdentifiers: [],
            options: UNNotificationCategoryOptions(rawValue: 0))
        UNUserNotificationCenter.current().setNotificationCategories([sentTabCategory])
    }
}

extension AppDelegate {
    func pushNotificationSetup() {

       UNUserNotificationCenter.current().delegate = self
      // SentTabAction.registerActions()

        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            guard error == nil else {
                return
            }
            if granted {
                DefaultNotificationScheduler.firstTimeSchedule()
                DockNotificationScheduler.firstTimeSchedule()

            }
        }
    }

    private func openURLsInNewTabs(_ notification: UNNotification) {
        guard let urls = notification.request.content.userInfo["sentTabs"] as? [NSDictionary]  else { return }
        for sentURL in urls {
            if let urlString = sentURL.value(forKey: "url") as? String, let url = URL(string: urlString) {
                receivedURLs.append(url)
            }
        }

        // Check if the app is foregrounded, _also_ verify the BVC is initialized. Most BVC functions depend on viewDidLoad() having run –if not, they will crash.
        if UIApplication.shared.applicationState == .active && browserViewController.isViewLoaded {
            browserViewController.loadQueuedTabs(receivedURLs: receivedURLs)
            receivedURLs.removeAll()
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Called when the user taps on a sent-tab notification from the background.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let isDefaultBrowserNotification = DefaultBrowserNotification.allCases.contains { $0.rawValue ==  response.notification.request.identifier }
        let isDockNotification = DockNotification.allCases.contains { $0.rawValue ==  response.notification.request.identifier }
        
        if (response.notification.request.content.userInfo["sentTabs"] as? [NSDictionary]) != nil {
            openURLsInNewTabs(response.notification)
            return
        } else if isDefaultBrowserNotification {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
        } else if isDockNotification {
            if Locale.current.identifier.contains("fr") {
                receivedURLs.append(URL(string: "https://about.karmasearch.org/fr/dock_ios")!)
            } else {
                receivedURLs.append(URL(string: "https://about.karmasearch.org/dock_ios")!)
            }
            BrowserViewController.foregroundBVC().loadQueuedTabs(receivedURLs: receivedURLs)
        }
        
    }

    // Called when the user receives a tab (or any other notification) while in foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        if (notification.request.content.userInfo["sentTabs"] as? [NSDictionary]) != nil {
            if profile?.prefs.boolForKey(PendingAccountDisconnectedKey) ?? false {
                profile?.removeAccount()
                
                // show the notification
                completionHandler([.alert, .sound])
            } else {
                openURLsInNewTabs(notification)
            }
            return
        }

    }
}

extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        RustFirefoxAccounts.shared.pushNotifications.didRegister(withDeviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("failed to register. \(error)")
        SentryIntegration.shared.send(message: "Failed to register for APNS")
    }
}
