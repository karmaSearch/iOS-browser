// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation


struct LearnAndAct {
    let blocs: [LearnAndActBloc]
    
    static func parseJSON(list: [[String: Any]]) throws -> LearnAndAct {
        
        let blocs = list.compactMap({ (dict) -> LearnAndActBloc in
            let id = dict["id"] as? Int ?? 0
            let title = dict["title"] as? String ?? ""
            let description = dict["content"] as? String ?? ""
            let link = dict["destinationUrl"] as? String ?? ""
            let action = dict["destinationUrlLabel"] as? String ?? ""
            let typeId = dict["contentType"] as? String ?? ""
            let imageUrl = dict["imageUrl"] as? String ?? ""
            
            let publishedAt = dict["publishedAt"] as? String ?? ""
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
           // private val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)

            let publishedAtDate = dateFormatter.date(from:publishedAt) ?? Date()
            
            return LearnAndActBloc(id: id, imageURL: imageUrl, title: title, description: description, action: action, link: link, contentType: LearnAndActContentType(rawValue: typeId) ?? .undefined, publishedAt: publishedAtDate)
        }).sorted {
            $0.publishedAt == $1.publishedAt ? $0.id > $1.id : $0.publishedAt > $1.publishedAt  
        }
        
        return LearnAndAct(blocs: blocs)
        
        
    }
}

struct LearnAndActBloc {
    let id: Int
    let imageURL, title: String
    let description, action: String
    let link: String
    let contentType: LearnAndActContentType
    let publishedAt: Date
}

enum LearnAndActContentType: String {
    case news = "news"
    case victory = "victory"
    case act = "act"
    case learn = "learn"
    case undefined
    
}
