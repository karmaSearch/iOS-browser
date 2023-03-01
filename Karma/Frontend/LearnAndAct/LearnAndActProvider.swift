// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared
import CloudKit


protocol LearnAndActProviding {
    func fetchArticles(pageNumber: Int) async throws -> LearnAndAct
}


class LearnAndActProvider: LearnAndActProviding, FeatureFlaggable, URLCaching {

    private class LearnAndActError: MaybeErrorType {
        var description = "Failed to load from API"
    }

    private let learnAndActEnvAPIKey = "LearnAndActEnvironmentAPIKey"

    private static let SupportedLocales = ["en_CA", "en_US", "en_GB", "en_ZA", "fr_FR"]
    private var token: String?
    
    private let urlPost = "https://cms.karmasearch.org/api/posts"

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
        case token
    }

    func fetchArticles(pageNumber: Int = 1) async throws -> LearnAndAct {
        
       guard let request = await createRequest(pageNumber: pageNumber) else { throw Error.failure}
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
        guard let items = json else {
            throw Error.failure
        }
        
        return try LearnAndAct.parseJSON(list: items)

       
    }
    
    private func createRequest(pageNumber: Int = 1) async -> URLRequest?{
      
        let locale = Locale.current.identifier

        guard let url = URL(string: urlPost)?.withQueryParams([URLQueryItem(name: "populate[0]", value: "media"),
                                                               URLQueryItem(name: "populate[1]", value: "contentType"),
                                                               URLQueryItem(name: "pagination[page]", value: String(pageNumber)),
                                                               //URLQueryItem(name: "pagination[pageSize]", value: String(5)), //test pagination
                                                               URLQueryItem(name: "local", value: locale)]
        ) else { return nil }

        
        
        var request = URLRequest(url: url)
        
        if self.token == nil {
            self.token = try? await getToken()
        }
       
        if let token = self.token {
            request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }
    
    private func getToken() async throws -> String {
            
            let app = CKContainer(identifier: "iCloud.cmskey")

            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: "Keys", predicate: predicate)
                
         if #available(iOS 15.0, *) {
            let results = try await app.publicCloudDatabase.records(matching: query)
            let token = try results.matchResults.first?.1.get().value(forKey: "CMS_TOKEN") ?? ""
             if let token = token as? String {
                 return token
             }
             throw Error.token
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                
                app.publicCloudDatabase.perform(query, inZoneWith: nil) { (rec, error) in
                    let token = rec?.first?.object(forKey: "CMS_TOKEN")
                     
                    if let token = token as? String {
                        continuation.resume(with: .success(token))
                    } else {
                        continuation.resume(with: .failure(Error.token))
                    }
                }
            }
        }
    }
}
