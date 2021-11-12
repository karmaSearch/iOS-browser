/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import UIKit
import Shared
import SnapKit

struct DBOnboardingUX {
    static let textOffset = 20
    static let textOffsetSmall = 13
    static let fontSize: CGFloat = 24
    static let fontSizeSmall: CGFloat = 20
    static let fontSizeXSmall: CGFloat = 16
    static let titleSize: CGFloat = 28
    static let titleSizeSmall: CGFloat = 24
    static let titleSizeLarge: CGFloat = 34
    static let containerViewHeight = 350
    static let containerViewHeightSmall = 300
    static let containerViewHeightXSmall = 250
}

class DefaultBrowserOnboardingViewController: UIViewController, OnViewDismissable {
    
    // MARK: - Properties
    
    var onViewDismissed: (() -> Void)? = nil
    // Public constants
    let viewModel = DefaultBrowserOnboardingViewModel()
    let theme = LegacyThemeManager.instance
    // Private vars
    private var fxTextThemeColour: UIColor {
        // For dark theme we want to show light colours and for light we want to show dark colours
        return theme.currentName == .dark ? .white : .black
    }
    private var fxBackgroundThemeColour: UIColor = UIColor.theme.onboarding.backgroundColor
    private var descriptionFontSize: CGFloat {
        return screenSize.height > 1000 ? DBOnboardingUX.fontSizeXSmall :
               screenSize.height > 668 ? DBOnboardingUX.fontSize :
               screenSize.height > 640 ? DBOnboardingUX.fontSizeSmall : DBOnboardingUX.fontSizeXSmall
    }
    private var titleFontSize: CGFloat {
        return screenSize.height > 1000 ? DBOnboardingUX.titleSizeLarge :
               screenSize.height > 640 ? DBOnboardingUX.titleSize : DBOnboardingUX.titleSizeSmall
    }
    // Orientation independent screen size
    private let screenSize = DeviceInfo.screenSizeOrientationIndependent()

    // UI
    private lazy var defaultBrowserView: DefaultBrowserOnboardingView = {
        let view = DefaultBrowserOnboardingView()
        view.translatesAutoresizingMaskIntoConstraints = true
        view.layoutSubviews()
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.Photon.DarkGrey90
        view.translatesAutoresizingMaskIntoConstraints = true
        view.layoutSubviews()
        return view
    }()

    // Used to set the part of text in center 
    private var containerView = UIView()
    
    // MARK: - Inits
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Portrait orientation: lock enable
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Portrait orientation: lock disable
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.all)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onViewDismissed?()
        onViewDismissed = nil
    }
    
    func initialViewSetup() {
        contentView.addSubviews(defaultBrowserView)
        view.addSubview(contentView)
        defaultBrowserView.closeClosure = { [weak self] in
            self?.dismissAnimated()
        }
        defaultBrowserView.settingsClosure = { [weak self] in
            self?.goToSettings()
        }
        // Constraints
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupView() {
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
            make.leading.trailing.equalToSuperview()
        }
        
        defaultBrowserView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.safeArea.bottom)
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(40)
        }
        
        let curve = UIImageView(image: UIImage(named: "bg-curves"))
        view.addSubview(curve)
        
        curve.snp.makeConstraints { make in
            make.bottom.equalTo(contentView.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        
    }
    
    
    // Button Actions
    @objc private func dismissAnimated() {
        self.dismiss(animated: true, completion: nil)
        TelemetryWrapper.recordEvent(category: .action, method: .tap, object: .dismissDefaultBrowserOnboarding)
    }
    
    @objc private func goToSettings() {
        viewModel.goToSettings?()
        UserDefaults.standard.set(true, forKey: "DidDismissDefaultBrowserCard") // Don't show default browser card if this button is clicked
        TelemetryWrapper.recordEvent(category: .action, method: .tap, object: .goToSettingsDefaultBrowserOnboarding)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
