//
//  SearchHeader.swift
//  Client
//
//  Created by Lilla on 18/11/2021.
//  Copyright © 2021 Mozilla. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class SearchHeader: UITableViewHeaderFooterView {
    var titleLabel: UILabel = .build { label in
        label.font = DynamicFontHelper.defaultHelper.DeviceFontLargeBold
        label.textColor = UIColor.Photon.DarkGrey70
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.safeArea.leading).inset(14)
            make.top.centerY.equalToSuperview()
        }
        contentView.backgroundColor = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
