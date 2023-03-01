//
//  IntroTutoView.swift
//  Client
//
//  Created by Lilla on 14/04/2022.
//  Copyright © 2022 Mozilla. All rights reserved.
//

import UIKit
import SnapKit
import Shared

class IntroTutoView: UIView {
    
    // Views
    private lazy var screenshotImage: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        return imgView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.customFontKG(ofSize: 18)
        label.text = .IntroTutorialTitle
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle(.IntroNextButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont.customFont(ofSize: 15, weight: .medium)
        button.setTitleColor(UIColor.Photon.White100, for: .normal)
        button.backgroundColor = UIColor.Photon.Green60
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.titleLabel?.textAlignment = .center
        button.accessibilityIdentifier = "nextOnboardingButton"
        return button
    }()
        
    // Helper views
    let bottomHolder = UIView()
    
    // Closure delegates
    var nextClosure: (() -> Void)?
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialViewSetup()
    }
    
    func setData(screenshotImage: String, titleButton: String) {
        self.screenshotImage.image = UIImage(named: screenshotImage)
        self.nextButton.setTitle(titleButton, for: .normal)
    }
    // MARK: View setup
    private func initialViewSetup() {
        
        addSubviews(titleLabel, screenshotImage, nextButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeArea.top).offset(20)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
        }
        
        screenshotImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(10)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
        }
        
        screenshotImage.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        nextButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(60)
            make.top.equalTo(screenshotImage.snp.bottom).offset(40)
            make.bottom.equalTo(safeArea.bottom).inset(60)
            make.height.equalTo(40)
        }
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
    }
    
    @objc private func nextAction() {
        nextClosure?()
        
    }
}
