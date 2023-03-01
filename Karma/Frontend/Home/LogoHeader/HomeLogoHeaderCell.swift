// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared
import UIKit

class HomeLogoHeaderCell: UICollectionViewCell, ReusableCell {
    private struct UX {
        struct Logo {
            static let imageWidth: CGFloat = 130
            static let imageHeight: CGFloat = 50
            static let topConstant: CGFloat = 5
            static let bottomConstant: CGFloat = 0
        }

    }

    typealias a11y = AccessibilityIdentifiers.FirefoxHomepage.OtherButtons

    // MARK: - UI Elements
    lazy var logoImage: UIImageView = .build { imageView in
        imageView.image = UIImage(named:  "karmaLogo") 
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityIdentifier = a11y.logoImage
    }


    // MARK: - Variables
    private var userDefaults: UserDefaults = UserDefaults.standard

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup
    func setupView() {
        contentView.backgroundColor = .clear
        contentView.addSubview(logoImage)

        NSLayoutConstraint.activate([
            logoImage.topAnchor.constraint(equalTo: contentView.topAnchor,
                                           constant: UX.Logo.topConstant),
            logoImage.widthAnchor.constraint(equalToConstant: UX.Logo.imageWidth),
            logoImage.heightAnchor.constraint(equalToConstant: UX.Logo.imageHeight),
            logoImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                              constant: UX.Logo.bottomConstant),
        ])
    }
}

// MARK: - Theme
extension HomeLogoHeaderCell: ThemeApplicable {
    func applyTheme(theme: Theme) {
       
    }
}
