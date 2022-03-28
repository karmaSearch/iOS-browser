/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import UIKit
import SnapKit
import Shared

class IntroScreenWelcomeView: UIView, CardTheme {

    // Views
    private lazy var animalsBackgroundImage: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        return imgView
    }()
    
    private lazy var iconImage: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        return imgView
    }()
    
    private lazy var karmaLogo: UIImageView = {
        let logo = UIImageView(image: UIImage(named: "karma-logo"))
        logo.contentMode = .scaleAspectFit
        logo.clipsToBounds = true
        
        return logo
    }()
    
    private lazy var aspasLogo: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        return imgView
    }()
    private lazy var l214Logo: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        return imgView
    }()
    private lazy var naatLogo: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        return imgView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.customFontKG(ofSize: 24)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private lazy var subTitleLabelPage1: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.Photon.LightGrey90
        label.font = UIFont.customFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 3
        label.baselineAdjustment = .alignCenters
        return label
    }()
    
    private var closeButton: UIButton = {
        let closeButton = UIButton()
        closeButton.tintColor = UIColor.Photon.Grey11
        closeButton.setTitle(.IntroButtonSkip, for: .normal)
        closeButton.titleLabel?.font = UIFont.customFont(ofSize: 18, weight: .medium)
        closeButton.setImage(UIImage(named: "skip-right-arrow"), for: .normal)
        closeButton.semanticContentAttribute = .forceRightToLeft
        return closeButton
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
    
    private var isLast: Bool = false
    
    // Helper views
    let main2panel = UIStackView()
    let imageHolder = UIView()
    let bottomHolder = UIView()
    // Closure delegates
    var closeClosure: (() -> Void)?
    var nextClosure: (() -> Void)?
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialViewSetup()
        TelemetryWrapper.recordEvent(category: .action, method: .view, object: .welcomeScreenView)
    }
    
    func setData(title: String, description: String, icon: String, aspas: String, l214:String, naat: String, background: String, isLast: Bool = false) {
        self.titleLabel.text = title
        self.subTitleLabelPage1.text = description
        self.animalsBackgroundImage.image = UIImage(named: background)
        self.iconImage.image = UIImage(named: icon)
        self.aspasLogo.image = UIImage(named: aspas)
        self.l214Logo.image = UIImage(named: l214)
        self.naatLogo.image = UIImage(named: naat)
        self.isLast = isLast
        self.closeButton.isHidden = isLast
    }
    
    // MARK: View setup
    private func initialViewSetup() {
        // Background colour setup
        backgroundColor = .white
        // View setup
        main2panel.axis = .vertical
        main2panel.distribution = .fill
        bottomHolder.backgroundColor = UIColor.Photon.DarkGrey90
        
        addSubview(main2panel)
        main2panel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(snp.top)
            make.bottom.equalTo(snp.bottom)
        }
        
        main2panel.addArrangedSubview(imageHolder)
        imageHolder.addSubview(animalsBackgroundImage)
        setUpCurveBackground()
        imageHolder.addSubviews(karmaLogo)
        
        karmaLogo.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(safeArea.top).inset(30)
        }
    
        animalsBackgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(main2panel.snp.height).multipliedBy(0.45)
            
        }
        
        // bottomHolder
        main2panel.addArrangedSubview(bottomHolder)
        
        
        

            
            [iconImage, titleLabel, subTitleLabelPage1, nextButton, aspasLogo, naatLogo, l214Logo].forEach {
                 bottomHolder.addSubview($0)
            }
            
            aspasLogo.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(160)
                make.top.equalTo(subTitleLabelPage1.snp.bottom).offset(5)
                
                make.height.equalTo(aspasLogo.snp.width).multipliedBy(0.20)
                
            }
            naatLogo.snp.makeConstraints { make in
                make.top.equalTo(subTitleLabelPage1.snp.bottom).offset(5)
                make.centerX.equalToSuperview()
                
                make.height.equalTo(naatLogo.snp.width).multipliedBy(0.20)
            }
            l214Logo.snp.makeConstraints { make in
                make.top.equalTo(subTitleLabelPage1.snp.bottom).offset(5)
                make.right.equalToSuperview().inset(160)
               
                make.height.equalTo(l214Logo.snp.width).multipliedBy(0.20)
                
            }
            nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
            nextButton.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(60)
                make.top.equalTo(aspasLogo.snp.bottom).offset(20)
                make.bottom.equalToSuperview().inset(120).priority(.medium)
                make.height.equalTo(40)
            }
            
            subTitleLabelPage1.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(40)
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
            }
         
            
            
          
        
        
        
      
        iconImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview().inset(5)
            make.top.equalToSuperview().inset(20).priority(.medium)
            make.height.equalTo(iconImage.snp.width).multipliedBy(0.44)
        }
       
        
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(iconImage.snp.bottom).offset(20)
        }
        
        
        
        addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(handleCloseButtonTapped), for: .touchUpInside)
        closeButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeArea.bottom).inset(15)
            make.right.equalToSuperview().inset(15)
        }

    }
    
    private func setUpCurveBackground() {
        let curve = UIImageView(image: UIImage(named: "bg-curves"))
        imageHolder.addSubview(curve)
        curve.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    // MARK: Button Actions
    @objc func handleCloseButtonTapped() {
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .welcomeScreenClose)
        closeClosure?()
    }
    
    @objc private func nextAction() {
        TelemetryWrapper.recordEvent(category: .action, method: .tap, object: .welcomeScreenNext)
        if isLast {
            closeClosure?()
        } else {
            nextClosure?()
        }
    }
    
    @objc private func dismissAnimated() {
        closeClosure?()
    }
}
