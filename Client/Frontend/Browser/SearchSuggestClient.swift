/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared

let SearchSuggestClientErrorDomain = "org.mozilla.firefox.SearchSuggestClient"
let SearchSuggestClientErrorInvalidEngine = 0
let SearchSuggestClientErrorInvalidResponse = 1

/*
 * Clients of SearchSuggestionClient should retain the object during the
 * lifetime of the search suggestion query, as requests are canceled during destruction.
 *
 * Query callbacks that must run even if they are cancelled should wrap their contents in `withExtendendLifetime`.
 */
class SearchSuggestClient {
    fileprivate let searchEngine: OpenSearchEngine
    fileprivate let userAgent: String
    fileprivate var task: URLSessionTask?

    lazy fileprivate var urlSession: URLSession = makeURLSession(userAgent: self.userAgent, configuration: URLSessionConfiguration.ephemeral)

    init(searchEngine: OpenSearchEngine, userAgent: String) {
        self.searchEngine = searchEngine
        self.userAgent = userAgent
    }

    func query(_ query: String, callback: @escaping (_ response: [String]?, _ error: NSError?) -> Void) {
        let url = searchEngine.suggestURLForQuery(query)
        if url == nil {
            let error = NSError(domain: SearchSuggestClientErrorDomain, code: SearchSuggestClientErrorInvalidEngine, userInfo: nil)
            callback(nil, error)
            return
        }

        task = urlSession.dataTask(with: url!) { (data, response, error) in
            if let error = error {
                callback(nil, error as NSError?)
                return
            }

            guard let data = data, let _ = validatedHTTPResponse(response, statusCode: 200..<300) else {
                let error = NSError(domain: SearchSuggestClientErrorDomain, code: SearchSuggestClientErrorInvalidResponse, userInfo: nil)
                callback(nil, error as NSError?)
                return
            }

            let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String]

            guard let json = json, !json.isEmpty else {
                let error = NSError(domain: SearchSuggestClientErrorDomain, code: SearchSuggestClientErrorInvalidResponse, userInfo: nil)
                callback(nil, error)
                return
            }
            
            let suggest = json
            callback(suggest, nil)
        }
        task?.resume()
    }

    func cancelPendingRequest() {
        task?.cancel()
    }
}
