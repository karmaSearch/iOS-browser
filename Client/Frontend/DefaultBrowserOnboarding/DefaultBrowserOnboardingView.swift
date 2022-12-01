//
//  DefaultBrowserOnboardingView.swift
//  Client
//
//  Created by Lilla on 12/11/2021.
//  Copyright © 2021 Mozilla. All rights reserved.
//

import UIKit

class DefaultBrowserOnboardingView: UIView {
  
    
    private lazy var titleLabel: UILabel = .build { label in
        label.textColor = .white
        label.text = .DefaultBrowserMenuItemKARMA
        label.font = UIFont.customFontKG(ofSize: 25)
        label.textAlignment = .center
        label.numberOfLines = 0
    }
    
    private lazy var subTitleLabelPage: UILabel = .build { label in
        label.textColor = UIColor.Photon.LightGrey90
        label.text = .DefaultBrowserCardDescription
        label.font = UIFont.customFont(ofSize: 15)
        label.textAlignment = .center
        label.numberOfLines = 0
    }
    
    private lazy var screenshotImage: UIImageView = .build { imgView in
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        imgView.image = UIImage(named: "default-browser-logo")
    }
    
    
    private lazy var chooseButton: UIButton = .build { button in
        button.setTitle(.DefaultBrowserOnboardingButtonKARMA, for: .normal)
        button.titleLabel?.font = DynamicFontHelper.defaultHelper.DeviceFontLargeBold
        button.setTitleColor(UIColor.Photon.White100, for: .normal)
        button.backgroundColor = UIColor.Photon.Green60
        button.clipsToBounds = true
        button.layer.cornerRadius = 20
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(self.goToSettingsAction), for: .touchUpInside)
    }
    
    private lazy var notNowButton: UIButton = .build { button in
        button.setTitle(.DefaultBrowserOnboardingButtonSkip, for: .normal)
        button.titleLabel?.font = DynamicFontHelper.defaultHelper.DeviceFont
        button.setTitleColor(UIColor.Photon.Green60, for: .normal)
        button.backgroundColor = UIColor.clear
        button.clipsToBounds = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(self.dismissAnimated), for: .touchUpInside)
    }
    
    var settingsClosure: (() -> Void)?
    var closeClosure: (() -> Void)?

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialViewSetup()
        
    }
    
    // MARK: View setup
    private func initialViewSetup() {
        
        addSubviews(titleLabel,subTitleLabelPage, screenshotImage, chooseButton, notNowButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeArea.top).offset(20)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
        }
        
        subTitleLabelPage.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.leading.equalTo(titleLabel.snp.leading)
        }
        
        screenshotImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().priority(.medium)
            make.leading.greaterThanOrEqualToSuperview().offset(20)
            make.top.greaterThanOrEqualTo(subTitleLabelPage.snp.bottom).offset(20)
        }
        
        screenshotImage.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        chooseButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(60)
            make.top.greaterThanOrEqualTo(screenshotImage.snp.bottom).offset(20)
            make.bottom.equalTo(notNowButton.snp.top).offset(-10)
            make.height.equalTo(40)
        }
        
        notNowButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeArea.bottom).offset(-30)
            make.height.equalTo(40)
        }
    }
    
    @objc private func goToSettingsAction() {
        settingsClosure?()
    }
    
    @objc private func dismissAnimated() {
        closeClosure?()
    }
  
}
