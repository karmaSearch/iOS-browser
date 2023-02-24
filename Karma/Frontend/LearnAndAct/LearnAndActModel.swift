// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation


struct LearnAndAct {
    let blocs: [LearnAndActBloc]
    let page: Int
    let numberOfPage: Int
    
    static func parseJSON(list: [String: Any]) throws -> LearnAndAct {
        guard let data = list["data"] as? [[String: Any]] else { throw LearnAndActProvider.Error.parsing }
        
        let blocs = data.compactMap({ (dict) -> LearnAndActBloc? in
            
            guard let attribute = dict["attributes"] as? [String: Any],
                  let title = attribute["title"] as? String,
                  let description = attribute["content"] as? String,
                  let link = attribute["destinationUrl"] as? String,
                  let action = attribute["destinationUrlLabel"] as? String,
                  let contentType = attribute["contentType"] as? [String: Any],
                  let data = contentType["data"] as? [String: Any],
                  let dataAttributes = data["attributes"] as? [String: Any],
                  let typeId = dataAttributes["value"] as? String,
                  let typeName = dataAttributes["name"] as? String,

                  let media = attribute["media"] as? [String: Any],
                  let dataMedia = media["data"] as? [String: Any],
                  let attributesMedia = dataMedia["attributes"] as? [String: Any],
                  let imageUrl = attributesMedia["url"] as? String
                  
            else { return nil }
        
            return LearnAndActBloc(imageURL: imageUrl, title: title, description: description, action: action, link: link, contentType: LearnAndActContentType(rawValue: typeId) ?? .undefined, contentString: typeName)
        })
        
        guard let meta = list["meta"] as? [String: Any],
              let pagination = meta["pagination"] as? [String: Any],
              let page = pagination["page"] as? Int,
              let numberOfPage = pagination["pageCount"] as? Int else {
            throw LearnAndActProvider.Error.parsing
        }
        return LearnAndAct(blocs: blocs, page: page, numberOfPage: numberOfPage)
        
        
    }
}

struct LearnAndActBloc {
    let imageURL, title: String
    let description, action: String
    let link: String
    let contentType: LearnAndActContentType
    let contentString: String
}

enum LearnAndActContentType: String {
    case news = "news"
    case victory = "victory"
    case act = "act"
    case learn = "learn"
    case undefined
}
