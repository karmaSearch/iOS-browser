//
//  KarmaHomeViewModel.swift
//  Client
//
//  Created by Lilla on 15/11/2021.
//  Copyright © 2021 Mozilla. All rights reserved.
//

import Foundation
import SwiftyJSON

struct HomeImage {
    var imageName: String
    var infoTitle: String?
    var author: String?
    var url: String?
}
class KarmaHomeViewModel {
    var currentImage: HomeImage?
    
    func getRandomImage() -> HomeImage {
        if let filePath = Bundle.main.path(forResource: "HomeImage", ofType: "json"),
           let data = NSData(contentsOfFile: filePath) {
          do {

              let json = try JSON(data: data as Data)
              let array = json["images"].arrayValue
              let random = Int.random(in: 0..<array.count)
                  
              let randomImage = array[random]
              self.currentImage = HomeImage(imageName: randomImage["imageName"].stringValue, infoTitle: randomImage["infoText"].stringValue, author: randomImage["author"].stringValue, url: randomImage["url"].stringValue)
              return currentImage!
          }
          catch {
            print(error)
          }
        }
        return HomeImage(imageName: "animal18", infoTitle: nil, author: nil)
    }
}
