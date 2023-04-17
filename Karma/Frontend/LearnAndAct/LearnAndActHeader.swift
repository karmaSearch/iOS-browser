//
//  LearnAndActHeader.swift
//  Client
//
//  Created by Lilla on 17/11/2021.
//  Copyright © 2021 Mozilla. All rights reserved.
//

import Foundation
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared


// Activity Stream header view
class LearnAndActHeader: UICollectionReusableView, ReusableCell {

    lazy var label: UILabel = .build { label in
        label.text = .LearnAndActTitle
        label.font = UIFont(name: "Amithen", size: 45)!
        label.textColor = UIColor.Photon.Green60
    }
    
    lazy var subTitleLabel: UILabel = .build { label in
        label.text = .LearnAndActSubTitle
        label.font = UIFont.customFont(ofSize: 15, weight: .regular)
        label.textColor = LegacyThemeManager.instance.current.homePanel.learnAndActTitleDescription
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(label, subTitleLabel)

        label.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(label.snp.bottom).offset(-10)

            make.bottom.equalToSuperview().offset(-10)
        }
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ThemeApplicable
extension LearnAndActHeader: ThemeApplicable {
    func applyTheme(theme: Theme) {
        subTitleLabel.textColor = LegacyThemeManager.instance.current.homePanel.learnAndActTitleDescription
    }
}
