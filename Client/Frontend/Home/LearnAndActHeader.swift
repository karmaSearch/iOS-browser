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



// Activity Stream header view
class LearnAndActHeader: UICollectionReusableView {
    
    lazy var imageView: UIImageView = .build { image in
        image.image = UIImage(named: "learn_and_act_header")
        image.contentMode = .scaleAspectFit
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview()
            make.height.equalTo(45)
            make.width.equalTo(185)
            make.bottom.equalToSuperview().offset(-10)
        }
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
