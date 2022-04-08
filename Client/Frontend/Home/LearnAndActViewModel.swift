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
    var blocs: [LearnAndActBloc] = []
    
    init(blocs: [LearnAndActBloc]){
        self.blocs = blocs
    }
    
}

// MARK: - Bloc
struct LearnAndActBloc: Decodable {
    let type, duration, mobileImage, desktopImage, title: String
    let description, action: String
    let link: String
    
    var defaultImageName: String {
        if type.lowercased() == "learn" {
            return "learn-crash-test"
        }
        return "act-crash-test"
    }
}


class LearnAndActViewModel {
    private let cacheKey: NSString = "LearnAndActCacheKey"
    static let cache = NSCache<NSString, LearnAndAct>()
    
    func getDatas(completion: @escaping (LearnAndAct) -> Void) {
        let fileName = Locale.current.identifier.contains("fr") ? "learn-and-act-fr" : "learn-and-act-en"
        let repoString = "https://storage.googleapis.com/learn-and-act-and-images.appspot.com/L%26A/json/"
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
                    let list = try JSONDecoder().decode([LearnAndActBloc].self, from: data)
                    
                    DispatchQueue.main.async {
                        let object = LearnAndAct(blocs: list)
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
