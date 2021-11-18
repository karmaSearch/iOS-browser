/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import UIKit
import Shared

class IntroViewController: UIViewController, OnViewDismissable {
    var onViewDismissed: (() -> Void)? = nil
    // private var
    // Private views
    private lazy var scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    private lazy var carouselStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var welcomeCard1: IntroScreenWelcomeView = {
        let welcomeCardView = IntroScreenWelcomeView()
        welcomeCardView.setData(title: .IntroSlidesTitle1, description: .IntroSlidesSubTitle1, icon: "welcome-icon-1", background: "welcome-background-1")
        welcomeCardView.translatesAutoresizingMaskIntoConstraints = false
        welcomeCardView.clipsToBounds = true
        return welcomeCardView
    }()
    
    private lazy var welcomeCard2: IntroScreenWelcomeView = {
        let welcomeCardView = IntroScreenWelcomeView()
        welcomeCardView.setData(title: .IntroSlidesTitle2, description: .IntroSlidesSubTitle2,  icon: "welcome-icon-2", background: "welcome-background-2")
        welcomeCardView.translatesAutoresizingMaskIntoConstraints = false
        welcomeCardView.clipsToBounds = true
        return welcomeCardView
    }()
    
    private lazy var welcomeCard3: IntroScreenWelcomeView = {
        let welcomeCardView = IntroScreenWelcomeView()
        welcomeCardView.setData(title: .IntroSlidesTitle3, description: .IntroSlidesSubTitle3, icon: "welcome-icon-3", background: "welcome-background-3", isLast: true)
        welcomeCardView.translatesAutoresizingMaskIntoConstraints = false
        welcomeCardView.clipsToBounds = true
        return welcomeCardView
    }()
    
    private lazy var defaultBrowserView: DefaultBrowserOnboardingView = {
        let view = DefaultBrowserOnboardingView()
        view.translatesAutoresizingMaskIntoConstraints = true
        view.layoutSubviews()
        return view
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = UIColor.Photon.Grey11
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = UIColor.Photon.Green60
        pageControl.addTarget(self, action: #selector(pageChanged), for: .valueChanged)
        return pageControl
    }()

    // Closure delegate
    var didFinishClosure: ((IntroViewController, FxAPageType?) -> Void)?
    let viewModel = DefaultBrowserOnboardingViewModel()
    
    // MARK: Initializer
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onViewDismissed?()
        onViewDismissed = nil
    }
    
    // MARK: View setup
    private func initialViewSetup() {
        view.backgroundColor = UIColor.Photon.DarkGrey90
        setupIntroView()
        setUpDefaultBrowser()
    }
    
    //onboarding intro view
    private func setupIntroView() {
        // Initialize
        view.addSubviews(scrollView)
        scrollView.addSubview(carouselStackView)
        
        
        // Constraints
        setUpScrollView()
        setUpCarousel()
    }
    
    private func setUpScrollView() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setUpCarousel() {
        [welcomeCard1, welcomeCard2, welcomeCard3].forEach { view in
            carouselStackView.addArrangedSubview(view)
            setupWelcomeCard(welcomeCard: view)
        }

        view.addSubviews(pageControl)

        NSLayoutConstraint.activate([
            carouselStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            carouselStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            carouselStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            carouselStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            carouselStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
        ])
        
        pageControl.numberOfPages = carouselStackView.arrangedSubviews.count
        pageControl.currentPage = 0
        
    }
                                
    private func setupWelcomeCard(welcomeCard: IntroScreenWelcomeView) {
        NSLayoutConstraint.activate([
            welcomeCard1.heightAnchor.constraint(equalTo: carouselStackView.heightAnchor),
            welcomeCard1.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Close button action
        welcomeCard.closeClosure = { [weak self] in
            guard let self = self else { return }
            let currentPage = self.pageControl.currentPage
            TelemetryWrapper.recordEvent(category: .action, method: .press, object: .dismissedOnboarding, extras: ["slide-num": currentPage])
            
            self.scrollView.isHidden = true
            self.pageControl.isHidden = true
            self.defaultBrowserView.isHidden = false
            self.defaultBrowserView.alpha = 0
            UIView.animate(withDuration: 1) {
                self.defaultBrowserView.alpha = 1
            }
        }
        
        welcomeCard.nextClosure = { [weak self] in
            guard let self = self else { return }
            self.pageControl.currentPage += 1
            self.pageChanged(self.pageControl)
        }
    }
    
    private func setUpDefaultBrowser() {
        view.addSubviews(defaultBrowserView)
        defaultBrowserView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview().offset(40)
            make.height.equalTo(445).priority(.medium)
            make.leading.equalToSuperview().offset(40)
        }
        
        defaultBrowserView.isHidden = true
        
        defaultBrowserView.closeClosure = { [weak self] in
            guard let self = self else { return }
            self.didFinishClosure?(self, nil)
        }
        defaultBrowserView.settingsClosure = { [weak self] in
            self?.goToSettings()
        }
    }
    
    @objc func pageChanged(_ sender: UIPageControl) {
        let page: Int = sender.currentPage
        var frame: CGRect = self.scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        self.scrollView.scrollRectToVisible(frame, animated: true)
    }
    
    @objc private func goToSettings() {
        viewModel.goToSettings?()
        UserDefaults.standard.set(true, forKey: "DidDismissDefaultBrowserCard") // Don't show default browser card if this button is clicked
        TelemetryWrapper.recordEvent(category: .action, method: .tap, object: .goToSettingsDefaultBrowserOnboarding)
    }
    
}

// MARK: UIViewController setup
extension IntroViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // This actually does the right thing on iPad where the modally
        // presented version happily rotates with the iPad orientation.
        return .portrait
    }
}

// MARK: UIScrollViewDelegate
extension IntroViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page : Int = Int(round(scrollView.contentOffset.x / 320))
        pageControl.currentPage = page
    }
}
