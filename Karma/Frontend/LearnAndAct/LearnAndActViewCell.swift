//
//  LearnAndActViewCell.swift
//  Client
//
//  Created by Lilla on 16/11/2021.
//  Copyright © 2021 Mozilla. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class LearnAndActViewCell: BlurrableCollectionViewCell, ReusableCell {
    
    struct UX {
        static let cellHeightLandscape: CGFloat = 159
        static let cellHeight: CGFloat = 330

        static let padding: CGFloat = 10
        static let padding2: CGFloat = 16
        static let textSpacing: CGFloat = 3
        static let imageHeight: CGFloat = 193
        static let typeHeight: CGFloat = 28
        static let cellWidth: CGFloat = 350
        static let interGroupSpacing: CGFloat = 8
        static let interItemSpacing = NSCollectionLayoutSpacing.fixed(8)
    }

    
    private lazy var imageView: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = false
    }
    
    private lazy var typeView: UIView = .build { view in
        view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
    }
    
    private lazy var titleLabel: UILabel = .build { label in
        label.font = UIFont.customFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 3
    }
    
    
    private lazy var typeLabel: UILabel = .build { label in
        label.font = UIFont.customFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .left
    }
    
    private lazy var typeImage: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = false
    }
    
    private lazy var timeToRead: UILabel = .build { label in
        label.font = UIFont.customFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
    }
    
    private lazy var descriptionLabel: UILabel = .build { label in
        label.font = UIFont.customFont(ofSize: 16, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 4
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.clipsToBounds = false
    }
    
    private lazy var linkLabel: UILabel = .build { label in
        label.font = UIFont.customFont(ofSize: 14, weight: .bold)
        label.textAlignment = .left
    }
    
    private lazy var textContent: UIView = .build { view in
    }
    
    private lazy var textStackView: UIStackView = .build { view in
        view.spacing = UX.textSpacing
        view.alignment = .leading
        view.axis = .vertical
        view.distribution = .equalSpacing
    }
    
    public var learnAndAct: LearnAndActCellViewModel? {
        didSet {
            guard let learnAndAct = learnAndAct else {
                return
            }
            titleLabel.text = learnAndAct.title
            typeLabel.text = learnAndAct.typeString.uppercased()
            timeToRead.text = learnAndAct.duration
            descriptionLabel.text = learnAndAct.description
            linkLabel.text = learnAndAct.action
            timeToRead.isHidden = learnAndAct.duration.isEmpty
            
            let url = URIFixup.getURL(learnAndAct.mobileImage)
            imageView.sd_setImage(with: url, placeholderImage: nil, completed: nil)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.maximumLineHeight = 20
            paragraphStyle.minimumLineHeight = 20
            
            let baselineOffSet = learnAndAct.duration.isEmpty ? 0 : 1
            
            descriptionLabel.attributedText = NSMutableAttributedString(string: learnAndAct.description, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle, .baselineOffset: baselineOffSet])
            descriptionLabel.lineBreakMode = .byTruncatingTail
            
            descriptionLabel.sizeToFit()
            
            applyTheme()

            typeView.isHidden = learnAndAct.typeIsHidden
            typeView.backgroundColor = learnAndAct.typeBackgroundColor
            typeImage.image = UIImage(named: learnAndAct.typeImageName)
            typeImage.tintColor = learnAndAct.typeLabelColor
            typeLabel.textColor = learnAndAct.typeLabelColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubviews(imageView, textContent, typeView)
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(timeToRead)
        textStackView.addArrangedSubview(descriptionLabel)
        textStackView.addArrangedSubview(linkLabel)
        textContent.addSubviews(textStackView)
        typeView.addSubviews(typeImage)
        typeView.addSubviews(typeLabel)
        
        if UITraitCollection.current.verticalSizeClass == .compact ||
            UIDevice.current.userInterfaceIdiom == .pad {
            typeView.snp.makeConstraints { make in
                make.leading.equalTo(imageView.snp.trailing)
                make.top.equalToSuperview()
                make.height.equalTo(UX.typeHeight)
            }
            
            imageView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.leading.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.4)
            }
            
            textContent.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.top.equalToSuperview()
                make.left.equalTo(imageView.snp.right)
                make.trailing.equalToSuperview()
            }
            
        } else {
            typeView.snp.makeConstraints { make in
                make.centerY.equalTo(imageView.snp.bottom)
                make.leading.equalToSuperview()
                make.height.equalTo(UX.typeHeight)
            }
            
            imageView.snp.makeConstraints { make in
                make.height.equalTo(UX.imageHeight)
                make.top.equalToSuperview()
                make.leading.trailing.equalToSuperview()
            }
            
            textContent.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.top.equalTo(imageView.snp.bottom).offset(UX.textSpacing)
                make.leading.trailing.equalToSuperview()
            }
        }
        
        typeImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
            make.leading.equalToSuperview().offset(UX.padding2)
        }
        
        typeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
            make.leading.equalTo(typeImage.snp.trailing).offset(UX.padding)
            make.trailing.equalToSuperview().offset(-UX.padding2)
        }
        
        textStackView.snp.makeConstraints { make in
            make.top.equalTo(typeView.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-UX.padding2)
            make.leading.equalToSuperview().offset(UX.padding2)
            make.centerX.equalToSuperview()
        }
        
        
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        addShadow()
    }
    
    func addShadow() {
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 4)
        
    }
    
    func updateViewConstraints() {
        if UITraitCollection.current.verticalSizeClass == .compact ||
            UIDevice.current.userInterfaceIdiom == .pad {
            typeView.snp.remakeConstraints { make in
                make.leading.equalTo(imageView.snp.trailing)
                make.top.equalToSuperview()
                make.height.equalTo(UX.typeHeight)
            }
            
            imageView.snp.remakeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.leading.equalToSuperview()
                make.width.equalTo(imageView.snp.height).multipliedBy(1.5)
            }
            
            textContent.snp.remakeConstraints { make in
                make.bottom.equalToSuperview()
                make.top.equalToSuperview()
                make.left.equalTo(imageView.snp.right)
                make.trailing.equalToSuperview()
            }
        } else {
            typeView.snp.remakeConstraints { make in
                make.centerY.equalTo(imageView.snp.bottom)
                make.leading.equalToSuperview()
                make.height.equalTo(UX.typeHeight)
            }
            
            imageView.snp.remakeConstraints { make in
                make.height.equalTo(UX.imageHeight)
                make.top.equalToSuperview()
                make.leading.trailing.equalToSuperview()
            }
            
            textContent.snp.remakeConstraints { make in
                make.bottom.equalToSuperview()
                make.top.equalTo(imageView.snp.bottom).offset(UX.textSpacing)
                make.leading.trailing.equalToSuperview()
            }
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass
            || self.traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass {
            updateViewConstraints()
        }
    }
    
    func applyTheme() {
        typeView.backgroundColor = UIColor.theme.homePanel.karmaTintColor
        titleLabel.textColor =  UIColor.theme.homePanel.learnAndActCellTitleColor
        typeLabel.textColor = UIColor.theme.homePanel.learnAndActTypeColor
        timeToRead.textColor = UIColor.theme.homePanel.learnAndActDurationColor
        descriptionLabel.textColor = UIColor.theme.homePanel.learnAndActDescriptionColor
        linkLabel.textColor = UIColor.theme.homePanel.learnAndActLinkColor
        textContent.backgroundColor = UIColor.theme.homePanel.learnAndActBackground
        contentView.backgroundColor = UIColor.theme.homePanel.learnAndActBackground
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
