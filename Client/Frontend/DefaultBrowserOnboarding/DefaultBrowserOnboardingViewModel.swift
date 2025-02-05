/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared

enum InstallType: String, Codable {
    case fresh
    case upgrade
    case unknown
    
    // Helper methods
    static func get() -> InstallType {
        guard let rawValue = UserDefaults.standard.string(forKey: PrefsKeys.InstallType), let type = InstallType(rawValue: rawValue) else {
            return unknown
        }
        return type
    }
    
    static func set(type: InstallType) {
        UserDefaults.standard.set(type.rawValue, forKey: PrefsKeys.InstallType)
        if dateOfFirstInstall() == nil {
            saveDateOfFirstInstall()
        } 
    }
    
    static func persistedCurrentVersion() -> String {
        guard let currentVersion = UserDefaults.standard.string(forKey: PrefsKeys.KeyCurrentInstallVersion) else {
            return ""
        }
        return currentVersion
    }
    
    static func updateCurrentVersion(version: String) {
        UserDefaults.standard.set(version, forKey: PrefsKeys.KeyCurrentInstallVersion)
    }
    
    private static func saveDateOfFirstInstall() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        UserDefaults.standard.set(formatter.string(from: Date()), forKey: PrefsKeys.DateFirstInstall)
    }
    
    static func dateOfFirstInstall() -> Date? {
        if let dateOfFirstInstall = UserDefaults.standard.object(forKey: PrefsKeys.DateFirstInstall) as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.date(from: dateOfFirstInstall)
        }
        return nil
    }
    
}

// Data Model
struct DefaultBrowserOnboardingModel {
    var titleText: String
    var descriptionText: [String]
    var imageText: String
}

class DefaultBrowserOnboardingViewModel {
    //  Internal vars
    var model: DefaultBrowserOnboardingModel?
    var goToSettings: (() -> Void)?

    init() {
        setupUpdateModel()
    }
    
    private func setupUpdateModel() {
        model = DefaultBrowserOnboardingModel(titleText: String.DefaultBrowserCardTitle, descriptionText: [String.DefaultBrowserCardDescription, String.DefaultBrowserOnboardingDescriptionStep1, String.DefaultBrowserOnboardingDescriptionStep2, String.DefaultBrowserOnboardingDescriptionStep3], imageText: String.DefaultBrowserOnboardingScreenshot)
    }
    
    static func shouldShowDefaultBrowserOnboarding(userPrefs: Prefs) -> Bool {
        guard #available(iOS 14, *) else {
            return false
        }
        // Only show on fresh install
        guard InstallType.get() == .fresh else { return false }
        
        // Show on 3rd session
        let maxSessionCount = 3
        var shouldShow = false
        // Get the session count from preferences
        let currentSessionCount = userPrefs.intForKey(PrefsKeys.SessionCount) ?? 0
        let didShow = UserDefaults.standard.bool(forKey: PrefsKeys.KeyDidShowDefaultBrowserOnboarding)
        guard !didShow else { return false }
        
        if currentSessionCount == maxSessionCount && currentSessionCount != 0 {
            shouldShow = true
            UserDefaults.standard.set(true, forKey: PrefsKeys.KeyDidShowDefaultBrowserOnboarding)
        }

        return shouldShow
    }
    

    
}
