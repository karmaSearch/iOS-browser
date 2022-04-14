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
        
        contentView.addSubview(menuButton)
        
        menuButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().inset(24)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func openMenu(_ sender: UIButton) {
        openMenu?(self.menuButton)
    }
    
}
