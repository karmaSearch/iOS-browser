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
        }) {
            if Locale.current.identifier.contains("-"),
               let firstPartIdentifier = Locale.current.identifier.split(separator: "-").first {
                return String(firstPartIdentifier)
            } else if Locale.current.identifier.contains("_"),
                let firstPartIdentifier = Locale.current.identifier.split(separator: "_").first{
                
                return String(firstPartIdentifier)
            }
            return Locale.current.identifier
           
        }
        
        return karmaDefaultLanguageIdentifier
        
    }
}

