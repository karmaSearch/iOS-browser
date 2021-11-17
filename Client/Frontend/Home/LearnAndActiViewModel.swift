//
//  LearnAndActiViewModel.swift
//  Client
//
//  Created by Lilla on 16/11/2021.
//  Copyright © 2021 Mozilla. All rights reserved.
//

import Foundation
import SwiftyJSON

struct LearnAndAct {
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


class LearnAndActiViewModel {
    
    func getDatas(completion: (LearnAndAct) -> Void) {
        if let filePath = Bundle.main.path(forResource: "learnandact", ofType: "json"),
           let data = NSData(contentsOfFile: filePath) {
          do {

              let json = try JSON(data: data as Data)
              completion( LearnAndAct(param: json))
          }
          catch {
            print(error)
          }
        }
    }
}
