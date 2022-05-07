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
import SDWebImageWebPCoder

class LearnAndActViewCell: UICollectionViewCell {
    private let padding: CGFloat = 10
    private let padding2: CGFloat = 16
    private let textSpacing: CGFloat = 3
    private let imageHeight: CGFloat = 193
    private let typeHeight: CGFloat = 24
    
    private lazy var imageView: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = false
    }
    
    private lazy var typeView: UIView = .build { view in
        view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
    }
    
    private lazy var titleLabel: UILabel = .build { label in
        label.font = UIFont.customFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 2
    }
    
    private lazy var typeLabel: UILabel = .build { label in
        label.font = UIFont.customFont(ofSize: 16, weight: .bold)
        label.textAlignment = .left
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
        view.spacing = self.textSpacing
        view.alignment = .leading
        view.axis = .vertical
        view.distribution = .equalSpacing
    }
    
    public var learnAndAct: LearnAndActBloc? {
        didSet {
            guard let learnAndAct = learnAndAct else {
                return
            }
            titleLabel.text = learnAndAct.title
            typeLabel.text = learnAndAct.type.uppercased()
            timeToRead.text = learnAndAct.duration
            descriptionLabel.text = learnAndAct.description
            linkLabel.text = learnAndAct.action
            timeToRead.isHidden = learnAndAct.duration.isEmpty
            
            let WebPCoder = SDImageWebPCoder.shared
            SDImageCodersManager.shared.addCoder(WebPCoder)
            SDWebImageDownloader.shared.setValue("image/webp,image/apng,image/*,*/*;q=0.8", forHTTPHeaderField:"Accept")
            let url = URIFixup.getURL(learnAndAct.mobileImage)
            imageView.sd_setImage(with: url, placeholderImage: UIImage(named: learnAndAct.defaultImageName), completed: nil)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.maximumLineHeight = 20
            paragraphStyle.minimumLineHeight = 20
            
            let baselineOffSet = learnAndAct.duration.isEmpty ? 0 : 1
            
            descriptionLabel.attributedText = NSMutableAttributedString(string: learnAndAct.description, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle, .baselineOffset: baselineOffSet])
            descriptionLabel.lineBreakMode = .byTruncatingTail
            
            descriptionLabel.sizeToFit()
            applyTheme()
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
        typeView.addSubview(typeLabel)
        
        if UITraitCollection.current.verticalSizeClass == .compact ||
            UIDevice.current.userInterfaceIdiom == .pad {
            typeView.snp.makeConstraints { make in
                make.leading.equalTo(imageView.snp.trailing)
                make.top.equalToSuperview()
                make.height.equalTo(typeHeight)
            }
            
            imageView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.leading.equalToSuperview()
                make.width.equalTo(imageView.snp.height).multipliedBy(1.5)
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
                make.height.equalTo(typeHeight)
            }
            
            imageView.snp.makeConstraints { make in
                make.height.equalTo(imageHeight)
                make.top.equalToSuperview()
                make.leading.trailing.equalToSuperview()
            }
            
            textContent.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.top.equalTo(imageView.snp.bottom).offset(textSpacing)
                make.leading.trailing.equalToSuperview()
            }
        }
        
        typeLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(padding2)
        }
        
        textStackView.snp.makeConstraints { make in
            make.top.equalTo(typeView.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-padding2)
            make.leading.equalToSuperview().offset(padding2)
            make.centerX.equalToSuperview()
        }
        
        
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true

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
                make.height.equalTo(typeHeight)
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
                make.height.equalTo(typeHeight)
            }
            
            imageView.snp.remakeConstraints { make in
                make.height.equalTo(imageHeight)
                make.top.equalToSuperview()
                make.leading.trailing.equalToSuperview()
            }
            
            textContent.snp.remakeConstraints { make in
                make.bottom.equalToSuperview()
                make.top.equalTo(imageView.snp.bottom).offset(textSpacing)
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
    
    func calculateSize(width: CGFloat) -> CGFloat {
        if UITraitCollection.current.verticalSizeClass == .compact ||
            UIDevice.current.userInterfaceIdiom == .pad {
            return 180
        }
        var size: CGFloat = 0
        size += imageHeight
        size += typeHeight / 2 
        size += textSpacing * 3
        size += titleLabel.font.calculateHeight(text: titleLabel.text ?? "", width: width - padding2*2)
        let sizeOfDescription = descriptionLabel.font.calculateHeight(text: descriptionLabel.text ?? "", width: width - padding2*2)
        size += min(sizeOfDescription, CGFloat(descriptionLabel.numberOfLines * 20))
        size += (timeToRead.text ?? "").isEmpty ? 0 : timeToRead.font.calculateHeight(text: timeToRead.text ?? "", width: width - padding2*2)
        size += linkLabel.font.calculateHeight(text: linkLabel.text ?? "", width: width - padding2*2)
        size += padding2
        return size
    }
    
}
