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

    private lazy var imageView: UIImageView = .build { imageView in
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = false
    }
    
    private lazy var typeView: UIView = .build { view in
        view.backgroundColor = UIColor.theme.homePanel.karmaTintColor
        view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
    }
    
    private lazy var titleLabel: UILabel = .build { label in
        label.font = UIFont.customFont(ofSize: 16, weight: .bold)
        label.textAlignment = .left
        label.textColor =  UIColor.theme.homePanel.learnAndActCellTitleColor
        label.numberOfLines = 2
    }
    
    private lazy var typeLabel: UILabel = .build { label in
        label.font = UIFont.customFont(ofSize: 10, weight: .bold)
        label.textAlignment = .left
        label.textColor = UIColor.theme.homePanel.learnAndActTypeColor
    }
    
    private lazy var timeToRead: UILabel = .build { label in
        label.font = UIFont.customFont(ofSize: 10, weight: .medium)
        label.textAlignment = .left
        label.textColor = UIColor.theme.homePanel.learnAndActDurationColor
    }
    
    private lazy var descriptionLabel: UILabel = .build { label in
        label.font = UIFont.customFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.textColor = UIColor.theme.homePanel.learnAndActDescriptionColor
        label.numberOfLines = 5
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.clipsToBounds = false
    }
    
    private lazy var linkLabel: UILabel = .build { label in
        label.font = UIFont.customFont(ofSize: 12, weight: .bold)
        label.textAlignment = .left
        label.textColor = UIColor.theme.homePanel.learnAndActLinkColor
    }
    
    private lazy var seprator: UIView = .build { view in
        view.backgroundColor = UIColor.theme.homePanel.separator
    }
    
    public var learnAndAct: LearnAndActBloc? {
        didSet {
            guard let learnAndAct = learnAndAct else {
                return
            }
            titleLabel.text = learnAndAct.blogArticleTitle
            typeLabel.text = learnAndAct.blocType.uppercased()
            timeToRead.text = learnAndAct.blogArticleDuration
            descriptionLabel.text = learnAndAct.blogArticleDescription
            linkLabel.text = learnAndAct.blogArticleAction
            let WebPCoder = SDImageWebPCoder.shared
            SDImageCodersManager.shared.addCoder(WebPCoder)
            SDWebImageDownloader.shared.setValue("image/webp,image/apng,image/*,*/*;q=0.8", forHTTPHeaderField:"Accept")
            
            imageView.sd_setImage(with: URL(string: "https://mykarma.org"+learnAndAct.blogArticleImage), completed: nil)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.maximumLineHeight = 18
            paragraphStyle.minimumLineHeight = 18
            
            let baselineOffSet = learnAndAct.blogArticleDuration.isEmpty ? 0 : 1
            
            descriptionLabel.attributedText = NSMutableAttributedString(string: learnAndAct.blogArticleDescription, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle, .baselineOffset: baselineOffSet])
            descriptionLabel.lineBreakMode = .byTruncatingTail
            
            let paragraphStyleForTitle = NSMutableParagraphStyle()
            paragraphStyleForTitle.lineHeightMultiple = 0.86
            titleLabel.attributedText = NSMutableAttributedString(string: learnAndAct.blogArticleTitle, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyleForTitle])
            
            descriptionLabel.sizeToFit()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubviews(imageView, titleLabel, typeView, timeToRead, timeToRead, descriptionLabel, linkLabel, seprator)
        
        typeView.addSubview(typeLabel)
        
        typeView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.greaterThanOrEqualTo(58)
            make.height.equalTo(17)
        }
        
        typeLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(padding)
        }
        
        imageView.snp.makeConstraints { make in
            make.width.equalTo(imageView.snp.height)
            make.top.equalTo(typeView.snp.centerY)
            make.centerY.equalToSuperview()
            make.leading.equalTo(padding2)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(typeView.snp.top)
            make.leading.equalTo(imageView.snp.trailing).offset(padding)
            make.trailing.equalToSuperview().offset(-padding)
        }
        
        timeToRead.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.equalTo(imageView.snp.trailing).offset(padding)
            make.trailing.equalToSuperview().offset(-padding)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(timeToRead.snp.bottom)
            make.leading.equalTo(imageView.snp.trailing).offset(padding)
            make.trailing.equalToSuperview().offset(-padding)
        }
        
        linkLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(1)
            make.leading.equalTo(imageView.snp.trailing).offset(padding)
            make.trailing.equalToSuperview().offset(-padding)
            make.bottom.lessThanOrEqualTo(imageView.snp.bottom)
            make.height.equalTo(13)
        }
        
        seprator.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
