// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

protocol LearnAndActDataAdaptor {
    func getLearnAndActData() -> LearnAndAct?
    func loadNewPage()
}

protocol LearnAndActDelegate: AnyObject {
    func didLoadNewData()
}

class LearnAndActDataAdaptorImplementation: LearnAndActDataAdaptor, FeatureFlaggable {

    private let learnAndActAPI: LearnAndActProviding
    private var learnAndAct: LearnAndAct?
    private var pageLoading: Int = 0
    weak var delegate: LearnAndActDelegate?
    private var lastLearnAndAct: LearnAndAct?


    init(API: LearnAndActProviding) {
        self.learnAndActAPI = API

        Task {
            await updateLearnAndAct()
        }
    }

    func getLearnAndActData() -> LearnAndAct? {
        return learnAndAct
    }

    private func updateLearnAndAct() async {
        do {
            pageLoading = 1
            learnAndAct = try await learnAndActAPI.fetchArticles(pageNumber: pageLoading)
            delegate?.didLoadNewData()
        } catch {
            print("Learn and act has en error ")
        }
    }
    
    func loadNewPage() {
        guard let learnAndAct = learnAndAct,
              !(lastLearnAndAct?.blocs.isEmpty ?? false) else { return }
        
        pageLoading = pageLoading+1
        Task {
            do {
                self.lastLearnAndAct = try await learnAndActAPI.fetchArticles(pageNumber: pageLoading)
                let newList = learnAndAct.blocs + self.lastLearnAndAct!.blocs
                self.learnAndAct = LearnAndAct(blocs: newList)

                delegate?.didLoadNewData()
            } catch {
                print("Learn and act has en error ")
            }
        }
    }
}
