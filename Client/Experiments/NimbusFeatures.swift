/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

/// This file contains configuration objects for application features that can be configured with Nimbus.
/// Eventually, this file may be auto-generated.

import Foundation
import MozillaAppServices

// This struct is populated from JSON coming from nimbus, with for `homescreen`
// feature id. The default values (i.e. user isn't enrolled in an experiment, or
// nimbus is unavailable can be represented in JSON like so:
//
// ```json
// {
//    "sections-enabled": {
//        "topSites": true,
//        "jumpBackIn": false,
//        "recentlySaved": false,
//        "pocket": false,
//        "libraryShortcuts": true,
//    }
// }
// ```
struct Homescreen {
    enum SectionId: String, CaseIterable {
        case karmahome
        case topSites
        case jumpBackIn
        case recentlySaved
        case pocket
        case libraryShortcuts
        case learnandact
    }

    var fullSectionsEnabled: [SectionId: Bool] = {
        return [.karmahome: true, .topSites: true, .learnandact: true]
    }()
    
    var reduceSectionsEnabled: [SectionId: Bool] = {
        return [.topSites: true, .libraryShortcuts: true]
    }()

}
