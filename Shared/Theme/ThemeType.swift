// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit

public enum ThemeType: String {
    case light
    case dark
    case lightKarma = "normal"   // This needs to match the string used in the legacy system
    case darkKarma

    public func getInterfaceStyle() -> UIUserInterfaceStyle {
        switch self {
        case .light, .lightKarma:
            return .light
        case .dark, .darkKarma:
            return .dark
        }
    }

    public func getBarStyle() -> UIBarStyle {
        switch self {
        case .light, .lightKarma:
            return .default
        case .dark, .darkKarma:
            return .black
        }
    }

    public func getThemedImageName(name: String) -> String {
        switch self {
        case .light, .lightKarma:
            return name
        case .dark, .darkKarma:
            return "\(name)_dark"
        }
    }
}
