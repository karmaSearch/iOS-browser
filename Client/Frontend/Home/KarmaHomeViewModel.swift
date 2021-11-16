//
//  KarmaHomeViewModel.swift
//  Client
//
//  Created by Lilla on 15/11/2021.
//  Copyright © 2021 Mozilla. All rights reserved.
//

import Foundation
struct HomeImage {
    var imageName: String
    var infoTitle: String?
    var author: String?
}
class KarmaHomeViewModel {
    
    func getRandomImage() -> HomeImage {
        if let filePath = Bundle.main.path(forResource: "HomeImage", ofType: "json"),
           let data = NSData(contentsOfFile: filePath) {
          do {
            let jsonString = try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)

              if let jsonData = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any],
                 let array = jsonData["images"] as? [Any] {
                  let random = Int.random(in: 0..<array.count)
                  
                  if let randomImage = array[random] as? [String: String] {
                      return HomeImage(imageName: randomImage["imageName"] ?? "", infoTitle: randomImage["infoText"] ?? "", author: randomImage["author"] ?? "")
                  }
              }
          }
          catch {
            print(error)
          }
        }
        return HomeImage(imageName: "animal18", infoTitle: nil, author: nil)
    }
}
