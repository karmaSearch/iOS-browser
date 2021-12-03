//
//  LearnAndActiViewModel.swift
//  Client
//
//  Created by Lilla on 16/11/2021.
//  Copyright © 2021 Mozilla. All rights reserved.
//

import Foundation
import SwiftyJSON

class LearnAndAct: NSObject {
    let blogLearnAndActDescription, blogLearnAndActNumberOfContent: String
    let blocs: [LearnAndActBloc]
    
    init(param: JSON) {
        blogLearnAndActDescription = param["blog_learn_and_act_description"].stringValue
        blogLearnAndActNumberOfContent = param["blog_learn_and_act_number_of_content"].stringValue
        blocs = param["blocs"].arrayValue.map { LearnAndActBloc(param: $0)}
    }
    
}

// MARK: - Bloc
struct LearnAndActBloc {
    let blocType, blogArticleDuration, blogArticleImage, blogArticleTitle: String
    let blogArticleDescription, blogArticleAction: String
    let blogArticleActionURL: String
    
    init(param: JSON) {
        blocType = param["bloc_type"].stringValue
        blogArticleDuration = param["blog_article_duration"].stringValue
        blogArticleImage = param["blog_article_image"].stringValue
        blogArticleTitle = param["blog_article_title"].stringValue
        blogArticleDescription = param["blog_article_description"].stringValue
        blogArticleAction = param["blog_article_action"].stringValue
        blogArticleActionURL = param["blog_article_action_url"].stringValue

    }
}


class LearnAndActViewModel {
    private let cacheKey: NSString = "LearnAndActCacheKey"
    static let cache = NSCache<NSString, LearnAndAct>()
    
    func getDatas(completion: @escaping (LearnAndAct) -> Void) {
        let fileName = Locale.current.identifier.contains("fr") ? "learnandact_fr" : "learnandact_en"
        let repoString = "https://about.mykarma.org/i18n/iOS_app/"
        guard let url = URL(string: repoString + fileName + ".json") else { return }
        
        if let cacheVersison = LearnAndActViewModel.cache.object(forKey: cacheKey) {
            completion(cacheVersison)
        } else {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                guard error == nil, let data = data else {
                    print(error!)
                    return
                }
                do {
                    let json = try JSON(data: data)
                    DispatchQueue.main.async {
                        let object = LearnAndAct(param: json)
                        LearnAndActViewModel.cache.setObject(object, forKey: self.cacheKey)
                        completion(object)
                    }
                }
                catch {
                    print(error)
                }
                
            }.resume()
        }
    }
}
