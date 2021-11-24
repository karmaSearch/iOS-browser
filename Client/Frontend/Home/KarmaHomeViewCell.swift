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
    private lazy var backgroundImageView: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
    }

    private lazy var infoButton: UIButton = .build { button in
        button.setImage(UIImage(named: "icon-info"), for: .normal)
        button.addTarget(self, action: #selector(self.showCredit(_:)), for: .touchUpInside)
    }
    
    private lazy var menuButton: UIButton = .build { button in
        button.setImage(UIImage(named: "icon-burger"), for: .normal)
        button.addTarget(self, action: #selector(self.openMenu(_:)), for: .touchUpInside)
    }
    
    private lazy var logoKarma: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "karma-logo")
    }
    
    private lazy var creditView: UIView = .build { view in
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
    }
    
    private lazy var descriptionLabel: UILabel = .build { label in
        label.textColor = UIColor.Photon.DarkGrey70
        label.font = DynamicFontHelper.defaultHelper.DefaultSmallFont
    }
    
    private lazy var autorLabel: UILabel = .build { label in
        label.textColor = UIColor.Photon.Purple70
        label.isUserInteractionEnabled = true
        label.font = DynamicFontHelper.defaultHelper.DefaultSmallFont
    }
    
    var viewModel: KarmaHomeViewModel = KarmaHomeViewModel()
    
    var openMenu: ((UIButton) -> Void)?
    var openLink: ((URL) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isAccessibilityElement = true
        accessibilityIdentifier = "Home"
        self.loadImages()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideCredit(_:)))
        backgroundImageView.addGestureRecognizer(tapGesture)
        
        let showLinkTap = UITapGestureRecognizer(target: self, action: #selector(self.showLink(_:)))
        creditView.addGestureRecognizer(showLinkTap)
        
        contentView.addSubviews(backgroundImageView, infoButton, menuButton, logoKarma, creditView)
        creditView.addSubviews(descriptionLabel, autorLabel)
        creditView.isHidden = true
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        infoButton.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview()
            make.size.equalTo(50)
        }
        
        menuButton.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
        }
        
        logoKarma.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }
        
        creditView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalTo(infoButton.snp.centerY)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
        autorLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-5)
            make.leading.equalTo(descriptionLabel.snp.trailing)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func openMenu(_ sender: UIButton) {
        openMenu?(self.menuButton)
    }
    
    @objc private func showLink(_ sender: UIButton) {
        if let urlString = viewModel.currentImage?.url,
           let url = URL(string: urlString){
            openLink?(url)
        }
    }
    
    @objc private func showCredit(_ sender: UIButton) {
        guard self.creditView.isHidden == true else { return }

        creditView.alpha = 0
        creditView.isHidden = false
        UIView.animate(withDuration: 1) { [weak self] in
            self?.creditView.alpha = 1
        }
    }
    
    @objc private func hideCredit(_ sender: UIButton) {
        guard self.creditView.isHidden == false else { return }
        
        creditView.alpha = 1
        UIView.animate(withDuration: 1) {  [weak self] in
            self?.creditView.alpha = 0
        } completion: {  [weak self] _ in
            self?.creditView.isHidden = true
        }
    }
    
    private func loadImages() {
        let image = viewModel.getRandomImage()
        backgroundImageView.image = UIImage(named: image.imageName)
        descriptionLabel.text = image.infoTitle
        autorLabel.text = image.author
        infoButton.isHidden = image.infoTitle == nil && image.author == nil
    }
}
