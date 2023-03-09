// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared
class AppUpdateManager {
    
    enum Status {
        case required
        case optional
        case noUpdate
    }

    func checkUpdateStatus(releaseDateInterval: TimeInterval = 7 * 24 * 60 * 60) async -> Status {

        guard let appVersion = try? Version(from: AppInfo.appVersion) else {
            return .noUpdate
        }

        // Get app info from App Store
        
        let iTunesURL = URL(string: "http://itunes.apple.com/lookup?bundleId=\(AppInfo.bundleIdentifier.replaceFirstOccurrence(of: "debug", with: ""))")

        guard let url = iTunesURL, let data = NSData(contentsOf: url) else {
            return .noUpdate
        }

        // Decode the response
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let response = try? decoder.decode(iTunesInfo.self, from: data as Data) else {
            return .noUpdate
        }

        // Verify that there is at least on result in the response
        guard response.results.count == 1, let appInfo = response.results.first else {
            return .noUpdate
        }

        let appStoreVersion = appInfo.version
        let releaseDate = appInfo.currentVersionReleaseDate

        let dateOneWeekAgo = Date(timeIntervalSinceNow: -releaseDateInterval)

        // Decide if it's a required or optional update based on the release date and the version change
        if case .orderedAscending = releaseDate.compare(dateOneWeekAgo) {
            if appStoreVersion.major > appVersion.major {
                return .required
            } else if (appStoreVersion.major == appVersion.major) &&
                        (appStoreVersion.minor > appVersion.minor) {
                return .optional
            } else if (appStoreVersion.major == appVersion.major) &&
                        (appStoreVersion.minor == appVersion.minor) &&
                        appStoreVersion.patch > appVersion.patch {
                return .optional
            }
        }
        return .noUpdate
    }

}
