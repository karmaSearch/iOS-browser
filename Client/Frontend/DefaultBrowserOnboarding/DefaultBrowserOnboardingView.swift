//
//  DefaultBrowserOnboardingView.swift
//  Client
//
//  Created by Lilla on 12/11/2021.
//  Copyright © 2021 Mozilla. All rights reserved.
//

import UIKit

class DefaultBrowserOnboardingView: UIView {
    private lazy var logoImage: UIImageView = .build { imgView in
        imgView.contentMode = .scaleToFill
        imgView.clipsToBounds = true
        imgView.image = UIImage(named: "default-browser-logo")
    }
    
    private lazy var titleLabel: UILabel = .build { label in
        label.textColor = .white
        label.text = "Set up KARMA as your default browser !"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
    }
    
    private lazy var subTitleLabelPage: UILabel = .build { label in
        label.textColor = UIColor.Photon.LightGrey90
        label.text = "Websites will be opened by KARMA so that you can help protect biodiversity and improve animal welfare"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
    }
    
    private lazy var chooseButton: UIButton = .build { button in
        button.setTitle("Choose KARMA", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .regular)
        button.setTitleColor(UIColor.Photon.White100, for: .normal)
        button.setBackgroundColor(UIColor.Photon.Green60, forState: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 12
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(self.goToSettingsAction), for: .touchUpInside)
    }
    
    private lazy var notNowButton: UIButton = .build { button in
        button.setTitle("Not now", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .regular)
        button.setTitleColor(UIColor.Photon.Green60, for: .normal)
        button.setBackgroundColor(UIColor.clear, forState: .normal)
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

        let stackView = UIStackView(arrangedSubviews: [logoImage, titleLabel, subTitleLabelPage])
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        
        addSubviews(stackView, chooseButton, notNowButton)
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        logoImage.snp.makeConstraints { make in
            make.height.equalTo(111)
            make.width.equalTo(111)
        }
        
        chooseButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(stackView.snp.bottom).offset(30)
            make.height.equalTo(36)
        }
        
        notNowButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(chooseButton.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
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
