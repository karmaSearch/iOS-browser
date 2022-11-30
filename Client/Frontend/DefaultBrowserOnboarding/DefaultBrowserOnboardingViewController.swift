// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Foundation
import UIKit
import Shared
import SnapKit

class DefaultBrowserOnboardingViewController: UIViewController, OnViewDismissable {

    // MARK: - Properties

    var onViewDismissed: (() -> Void)?
    // Public constants
    let viewModel = DefaultBrowserOnboardingViewModel()
    let theme = LegacyThemeManager.instance

    // Private vars
    
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
        OrientationLockUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Portrait orientation: lock disable
        OrientationLockUtility.lockOrientation(UIInterfaceOrientationMask.all)
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

    private func setupView() {
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(558).priority(.medium)
            make.height.lessThanOrEqualToSuperview()
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
        UserDefaults.standard.set(true, forKey: PrefsKeys.DidDismissDefaultBrowserMessage) // Don't show default browser card if this button is clicked
        TelemetryWrapper.recordEvent(category: .action, method: .tap, object: .goToSettingsDefaultBrowserOnboarding)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
