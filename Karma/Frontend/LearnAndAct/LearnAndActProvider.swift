// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared


protocol LearnAndActProviding {
    func fetchArticles(pageNumber: Int) async throws -> LearnAndAct
}


class LearnAndActProvider: LearnAndActProviding, FeatureFlaggable, URLCaching {

    private class LearnAndActError: MaybeErrorType {
        var description = "Failed to load from API"
    }
    
    private static let SupportedLocales = ["en_CA", "en_US", "en_GB", "en_ZA", "fr_FR"]
    private var token: String?
    
    private let urlPost = "https://api.karmasearch.org/posts"
    
    var urlCache: URLCache {
        return URLCache.shared
    }
    
    lazy private var urlSession = makeURLSession(userAgent: UserAgent.defaultClientUserAgent, configuration: URLSessionConfiguration.default)
    
    enum Error: Swift.Error {
        case failure
        case parsing
        case token
    }
    
    func fetchArticles(pageNumber: Int = 1) async throws -> LearnAndAct {
        
        guard let request = await createRequest(pageNumber: pageNumber) else { throw Error.failure}
        if pageNumber == 1, let cacheResponse = findCachedResponse(for: request),
           let items = cacheResponse["learnAndAndAct"] as? [[String: Any]] {
            return try LearnAndAct.parseJSON(list: items)
        }
        
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let response = validatedHTTPResponse(response, contentType: "application/json") else {
            throw Error.failure
        }
        
        self.cache(response: response, for: request, with: data)
        
        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]]
        guard let items = json else {
            throw Error.failure
        }
        
        return try LearnAndAct.parseJSON(list: items)

       
    }
    
    private func createRequest(pageNumber: Int = 1) async -> URLRequest?{
        
        let locale = Locale.current.identifier.replaceFirstOccurrence(of: "_", with: "-")
        guard let url = URL(string: urlPost)?.withQueryParams([
            URLQueryItem(name: "pageNumber", value: String(pageNumber)),
            //URLQueryItem(name: "pageSize", value: String(30)), //test pagination
            URLQueryItem(name: "locale", value: locale)]
        ) else { return nil }
        
        
        return URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
    }
    
}
