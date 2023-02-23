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

    private let learnAndActEnvAPIKey = "LearnAndActEnvironmentAPIKey"

    private static let SupportedLocales = ["en_CA", "en_US", "en_GB", "en_ZA", "fr_FR"]

    let urlPost = "http://app-9b20e7d8-1af6-4aad-8ec2-7f5d7278f128.cleverapps.io/api/posts"

    var urlCache: URLCache {
        return URLCache.shared
    }

    lazy private var urlSession = makeURLSession(userAgent: UserAgent.defaultClientUserAgent, configuration: URLSessionConfiguration.default)

    private lazy var pocketKey: String? = {
        return Bundle.main.object(forInfoDictionaryKey: learnAndActEnvAPIKey) as? String
    }()

    enum Error: Swift.Error {
        case failure
        case parsing
    }

    func fetchArticles(pageNumber: Int = 1) async throws -> LearnAndAct {
        
       guard let request = createRequest(pageNumber: pageNumber) else { throw Error.failure}
        if let cacheResponse = findCachedResponse(for: request),
           let items = cacheResponse["learnAndAndAct"] as? [String: Any] {
            return try LearnAndAct.parseJSON(list: items)
        }

        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let response = validatedHTTPResponse(response, contentType: "application/json") else {
            throw Error.failure
        }
        
        self.cache(response: response, for: request, with: data)
        
        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        guard let items = json as? [String: Any] else {
            throw Error.failure
        }
        
        return try LearnAndAct.parseJSON(list: items)

       
    }
    
    private func createRequest(pageNumber: Int = 1) -> URLRequest?{
      
        let locale = Locale.current.identifier
        let token = ""
        
        guard let url = URL(string: urlPost)?.withQueryParams([URLQueryItem(name: "populate[0]", value: "media"),
                                                               URLQueryItem(name: "populate[1]", value: "contentType"),
                                                               URLQueryItem(name: "pagination[page]", value: String(pageNumber)),
                                                               //URLQueryItem(name: "pagination[pageSize]", value: String(5)), //test pagination
                                                               URLQueryItem(name: "local", value: locale)]
        ) else { return nil }

        
        
        var request = URLRequest(url: url)
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")

        
        return request
    }
}
