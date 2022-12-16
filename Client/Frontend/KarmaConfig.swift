//
//  KarmaConfig.swift
//  Client
//
//  Created by Lilla on 21/04/2022.
//  Copyright © 2022 Mozilla. All rights reserved.
//

import Foundation

class KarmaLanguage {
    private static let karmaSupportedLanguagesIdentifier: [String] = ["fr", "en", "es"]

    private static let karmaDefaultLanguageIdentifier: String = "en"

    static func getSupportedLanguageIdentifier() -> String {
        if (karmaSupportedLanguagesIdentifier.contains {
            Locale.current.identifier.contains($0)
        }), let firstPartIdentifier = Locale.current.identifier.split(separator: "-").first {
            
            return String(firstPartIdentifier)
        }
        
        return karmaDefaultLanguageIdentifier
        
    }
}

