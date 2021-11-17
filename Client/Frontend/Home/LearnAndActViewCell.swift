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
        view.backgroundColor = UIColor.Photon.Green60
        view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
    }
    
    private lazy var titleLabel: UILabel = .build { label in
        label.font = DynamicFontHelper.defaultHelper.DefaultMediumBoldFont
        label.textAlignment = .left
        label.textColor = UIColor.Photon.DarkGrey90
        label.numberOfLines = 2
    }
    
    private lazy var typeLabel: UILabel = .build { label in
        label.font = DynamicFontHelper.defaultHelper.DefaultMediumFont
        label.textAlignment = .center
        label.textColor = UIColor.Photon.DarkGrey90
    }
    
    private lazy var timeToRead: UILabel = .build { label in
        label.font = DynamicFontHelper.defaultHelper.DefaultMediumFont
        label.textAlignment = .left
        label.textColor = UIColor(rgba: 0x94a1b2)
    }
    
    private lazy var descriptionLabel: UILabel = .build { label in
        label.font = DynamicFontHelper.defaultHelper.DefaultMediumFont
        label.textAlignment = .left
        label.textColor = UIColor(rgba: 0x242629)
        label.numberOfLines = 5
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    private lazy var linkLabel: UILabel = .build { label in
        label.font = DynamicFontHelper.defaultHelper.DefaultSmallFontBold
        label.textAlignment = .left
        label.textColor = UIColor.Photon.Green60
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
        
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubviews(imageView, titleLabel, typeView, timeToRead, titleLabel, timeToRead, descriptionLabel, linkLabel)
        
        typeView.addSubview(typeLabel)
        
        typeView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(padding)
            make.leading.equalToSuperview()
            make.width.greaterThanOrEqualTo(65)
            make.height.equalTo(17)
        }
        
        typeLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(padding)
        }
        
        imageView.snp.makeConstraints { make in
            make.width.equalTo(imageView.snp.height)
            make.width.equalToSuperview().multipliedBy(0.33)
            make.top.equalTo(typeView.snp.centerY)
            make.centerY.equalToSuperview()
            make.leading.equalTo(padding2)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(padding)
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
            make.top.equalTo(descriptionLabel.snp.bottom)
            make.leading.equalTo(imageView.snp.trailing).offset(padding)
            make.trailing.equalToSuperview().offset(-padding)
            make.bottom.lessThanOrEqualToSuperview().offset(-padding)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
