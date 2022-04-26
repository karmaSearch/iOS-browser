//
//  KarmaHomeViewCell.swift
//  Client
//
//  Created by Lilla on 15/11/2021.
//  Copyright © 2021 Mozilla. All rights reserved.
//

import Foundation
import UIKit

class KarmaHomeViewCell: UICollectionViewCell {

    private lazy var logoImageView: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "karma_logo")
    }
    private lazy var menuButton: UIButton = .build { button in
        button.setImage(UIImage(named: "icon-burger"), for: .normal)
        button.addTarget(self, action: #selector(self.openMenu(_:)), for: .touchUpInside)
        button.tintColor = LegacyThemeManager.instance.current.homePanel.menuColor
    }
    var viewModel: KarmaHomeViewModel = KarmaHomeViewModel()
    
    var openMenu: ((UIButton) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isAccessibilityElement = true
        accessibilityIdentifier = "Home"
        
        contentView.addSubviews(menuButton, logoImageView)
        
        menuButton.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
        }
        
        logoImageView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview()
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func openMenu(_ sender: UIButton) {
        openMenu?(self.menuButton)
    }
    
}
