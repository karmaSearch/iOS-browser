// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation


struct LearnAndAct {
    let blocs: [LearnAndActBloc]
    
    static func parseJSON(list: [[String: Any]]) throws -> LearnAndAct {
        
        let blocs = list.compactMap({ (dict) -> LearnAndActBloc? in
            
            guard let title = dict["title"] as? String,
                  let description = dict["content"] as? String,
                  let link = dict["destinationUrl"] as? String,
                  let action = dict["destinationUrlLabel"] as? String,
                  let typeId = dict["contentType"] as? String,
                  let imageUrl = dict["imageUrl"] as? String
                  
            else { return nil }
        
            return LearnAndActBloc(imageURL: imageUrl, title: title, description: description, action: action, link: link, contentType: LearnAndActContentType(rawValue: typeId) ?? .undefined)
        })
        
        return LearnAndAct(blocs: blocs)
        
        
    }
}

struct LearnAndActBloc {
    let imageURL, title: String
    let description, action: String
    let link: String
    let contentType: LearnAndActContentType
}

enum LearnAndActContentType: String {
    case news = "news"
    case victory = "victory"
    case act = "act"
    case learn = "learn"
    case undefined
    
}
