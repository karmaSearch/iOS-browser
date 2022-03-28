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
        label.text = .DefaultBrowserMenuItem
        label.font = UIFont.customFontKG(ofSize: 25)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
    }
    
    private lazy var subTitleLabelPage: UILabel = .build { label in
        label.textColor = UIColor.Photon.LightGrey90
        label.text = .DefaultBrowserCardDescription
        label.font = UIFont.customFont(ofSize: 17)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
    }
    
    private lazy var logoImage: UIImageView = .build { imgView in
        imgView.contentMode = .scaleToFill
        imgView.clipsToBounds = true
        if Locale.current.identifier.contains("fr") {
            imgView.image = UIImage(named: "default-browser-logo-fr")
            
        }else{
            imgView.image = UIImage(named: "default-browser-logo")
            
        }
        
    }
    
    
    private lazy var chooseButton: UIButton = .build { button in
        button.setTitle(.DefaultBrowserOnboardingButton, for: .normal)
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

       
        
        addSubviews(titleLabel,subTitleLabelPage, logoImage, chooseButton, notNowButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        subTitleLabelPage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(10)
            
        }
        
        logoImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(subTitleLabelPage.snp.bottom).offset(50)
            
        }
        
        chooseButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(logoImage.snp.bottom).offset(60)
            make.height.equalTo(36)
        }
        
        notNowButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            
            make.top.equalTo(chooseButton.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(30)
            make.height.equalTo(36)
        }
    }
    
    @objc private func goToSettingsAction() {
        settingsClosure?()
    }
    
    @objc private func dismissAnimated() {
        closeClosure?()
    }
  
}
