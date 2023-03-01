//
//  NotificationScheduler.swift
//  NotificationService
//
//  Created by Lilla on 20/12/2021.
//  Copyright © 2021 Mozilla. All rights reserved.
//

import Foundation
import NotificationCenter
import Shared

enum DefaultBrowserNotification: String, CaseIterable {
    case TwoDaysAfterInstall
    case OneMonthAfterInstall
    case SixMonthsAfterInstall

    var numberOfDaysAfterInstall: Int {
        switch self {
        case .TwoDaysAfterInstall: return 2
        case .OneMonthAfterInstall: return 30
        case .SixMonthsAfterInstall: return 30*6
        }
    }
    
    var timeInterval: TimeInterval {
        return TimeInterval(60*60*24*numberOfDaysAfterInstall)
    }
    
    var delayOfNonOpenedBeforePush: Int {
        switch self {
        case .TwoDaysAfterInstall: return 1
        case .OneMonthAfterInstall: return 7
        case .SixMonthsAfterInstall: return 7
        }
    }
    
}

class DefaultNotificationScheduler {

    static func firstTimeSchedule() {
        guard #available(iOS 14, *) else {
            return
        }
        guard !UserDefaults.standard.bool(forKey: "DefaultNotificationScheduler") else {
            return
        }
        DefaultBrowserNotification.allCases.forEach {
            self.addNotificationInterval(notificationType: $0)
        }
        UserDefaults.standard.set(true, forKey: "DefaultNotificationScheduler")
    }
    
    static func checkSchedule() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getPendingNotificationRequests { requests in
            
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let dateOfFistInstall = InstallType.dateOfFirstInstall(),
            let previousRequest = requests.first,
           let lastOpen = (UserDefaults.standard.array(forKey: "DATES_OF_LAUNCH") as? [String])?.last,
           let lastOpenDate = formatter.date(from: lastOpen),
           let notificationType = DefaultBrowserNotification(rawValue: previousRequest.identifier) {
            
            
            let sceduleDate = dateOfFistInstall.addingTimeInterval(notificationType.timeInterval)
            
            let intervalToCancel =  Calendar.current.date(byAdding: .day, value: -notificationType.delayOfNonOpenedBeforePush, to: sceduleDate)!
            
            //if app was opened X days before push date -> remove push
            if (intervalToCancel ... sceduleDate).contains(lastOpenDate) {
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [previousRequest.identifier])
            }

        }
            
        }
    }
    
    static func saveAppLaunch() {
        var launchDates: [String] = []
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let now = formatter.string(from: Date())

        if let datesOfLaunchSaved = UserDefaults.standard.array(forKey: "DATES_OF_LAUNCH") as? [String] {
            launchDates.append(contentsOf: datesOfLaunchSaved)
            //If the app had been launched today, do nothing else save today
            if datesOfLaunchSaved.first(where: { $0 == now }) == nil {
                launchDates.append(now)
            }
        } else {
            launchDates.append(now)
        }
        
        UserDefaults.standard.set(launchDates, forKey: "DATES_OF_LAUNCH")
    }
    
    
    private static func addNotificationInterval(notificationType: DefaultBrowserNotification) {
        let content = UNMutableNotificationContent()
        content.title = .DefaultBrowserPushTitle
        content.body = .DefaultBrowserPushMessage
        
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
