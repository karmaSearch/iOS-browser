//
//  DockNotificationScheduler.swift
//  Client
//
//  Created by Lilla on 04/08/2022.
//  Copyright © 2022 Mozilla. All rights reserved.
//

import Foundation
import NotificationCenter

enum DockNotification: String, CaseIterable {
    case OneHourAfterInstall
    case TwoDayAfterInstall

    var timeInterval: TimeInterval {
        switch self {
        case .OneHourAfterInstall:
            return TimeInterval(60*60)
        case .TwoDayAfterInstall:
            return TimeInterval(60*60*24*2)
        }
        
    }
    
}


class DockNotificationScheduler {

    static func firstTimeSchedule() {
        guard !UserDefaults.standard.bool(forKey: "DockNotificationScheduler") else {
            return
        }
        DockNotification.allCases.forEach {
            self.addNotificationInterval(notificationType: $0)
        }
        UserDefaults.standard.set(true, forKey: "DockNotificationScheduler")

    }
    
    private static func addNotificationInterval(notificationType: DockNotification) {
        let content = UNMutableNotificationContent()
        content.title = .DockPushTitle
        content.body = .DockPushMessage
        let url: String = "https://about.karmasearch.org/\(KarmaLanguage.getSupportedLanguageIdentifier())/dock_ios"
        let deeplink = "karma://open-url?url="+url
        content.userInfo["sentTabs"] = [NSDictionary(dictionary: ["url":deeplink])]
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: notificationType.timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: notificationType.rawValue, content: content, trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
           if let error = error {
              print(error)
           }
        }
    }
    
}
