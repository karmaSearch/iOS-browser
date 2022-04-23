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
    
    private lazy var closeButton: UIButton = {
        let closeButton = UIButton()
        closeButton.tintColor = UIColor.Photon.Grey11
        closeButton.setTitle(.IntroButtonSkip, for: .normal)
        closeButton.titleLabel?.font = UIFont.customFont(ofSize: 18, weight: .medium)
        closeButton.setImage(UIImage(named: "skip-right-arrow"), for: .normal)
        closeButton.semanticContentAttribute = .forceRightToLeft
        return closeButton
    }()

    private lazy var welcomeCard1: IntroScreenWelcomeView = {
        let welcomeCardView = IntroScreenWelcomeView()
        let logos: [String] = {
            if Locale.current.identifier.contains("fr") {
                return ["aspas-logo", "l214-logo", "naat-logo"]
            } else {
                return []
            }
        }()

        welcomeCardView.setData(title: .IntroSlidesTitle1, description: .IntroSlidesSubTitle1, icon: "welcome-icon-1" , logos: logos, background: "welcome-background-1")
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
        welcomeCardView.setData(title: .IntroSlidesTitle3, description: .IntroSlidesSubTitle3, icon: "welcome-icon-3", background: "welcome-background-3")
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
    
    private lazy var tutorialCard1: IntroTutoView = {
        let tutoCardView = IntroTutoView()
        tutoCardView.setData(screenshotImage: "screenshot_tuto_1", titleButton: .IntroNextButtonTitle)
        tutoCardView.translatesAutoresizingMaskIntoConstraints = false
        tutoCardView.clipsToBounds = true
        return tutoCardView
    }()
    
    private lazy var tutorialCard2: IntroTutoView = {
        let tutoCardView = IntroTutoView()
        tutoCardView.setData(screenshotImage: "screenshot_tuto_2", titleButton: .IntroNextButtonTitle)
        tutoCardView.translatesAutoresizingMaskIntoConstraints = false
        tutoCardView.clipsToBounds = true
        return tutoCardView
    }()
    
    private lazy var tutorialCard3: IntroTutoView = {
        let tutoCardView = IntroTutoView()
        tutoCardView.setData(screenshotImage: "screenshot_tuto_3", titleButton: .IntroButtonTitleLast)
        tutoCardView.translatesAutoresizingMaskIntoConstraints = false
        tutoCardView.clipsToBounds = true
        return tutoCardView
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
        if #available(iOS 14, *) {
            setUpDefaultBrowser()
        }
    }
    
    //onboarding intro view
    private func setupIntroView() {
        // Initialize
        view.addSubviews(scrollView)
        scrollView.addSubview(carouselStackView)
        
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(handleCloseButtonTapped), for: .touchUpInside)
        closeButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeArea.bottom).inset(15)
            make.right.equalToSuperview().inset(15)
        }
        
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
        
        [tutorialCard1, tutorialCard2, tutorialCard3].forEach { view in
            carouselStackView.addArrangedSubview(view)
            setupIntroCard(introCard: view)
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
        
        welcomeCard.nextClosure = { [weak self] in
            guard let self = self else { return }
            
            self.goToNextPage()
        }
    }
    
    private func setupIntroCard(introCard: IntroTutoView) {
        NSLayoutConstraint.activate([
            introCard.heightAnchor.constraint(equalTo: carouselStackView.heightAnchor),
            introCard.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        introCard.nextClosure = { [weak self] in
            guard let self = self else { return }
            self.goToNextPage()
        }
    }
    
    private func setUpDefaultBrowser() {
        view.addSubviews(defaultBrowserView)
        defaultBrowserView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        defaultBrowserView.isHidden = true
        
        defaultBrowserView.closeClosure = { [weak self] in
            guard let self = self else { return }
            self.didFinishClosure?(self, nil)
        }
        defaultBrowserView.settingsClosure = { [weak self] in
            guard let self = self else { return }
            self.goToSettings()
            self.didFinishClosure?(self, nil)
        }
    }
    
    private func goToNextPage() {
        if self.pageControl.currentPage == self.pageControl.numberOfPages-1 {
            self.handleCloseButtonTapped()
        } else {
            let isAnimated = self.pageControl.currentPage < 3
            self.pageControl.currentPage += 1
            self.pageChanged(self.pageControl, animated: isAnimated)
        }
    }
    
    @objc func pageChanged(_ sender: UIPageControl, animated: Bool = true) {
        let page: Int = sender.currentPage
        var frame: CGRect = self.scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        self.closeButton.isHidden = (page == sender.numberOfPages-1)
        self.scrollView.scrollRectToVisible(frame, animated: animated)
    }
    
    @objc private func goToSettings() {
        viewModel.goToSettings?()
        UserDefaults.standard.set(true, forKey: "DidDismissDefaultBrowserCard") // Don't show default browser card if this button is clicked
        TelemetryWrapper.recordEvent(category: .action, method: .tap, object: .goToSettingsDefaultBrowserOnboarding)
    }
    
    @objc func handleCloseButtonTapped() {
        let currentPage = self.pageControl.currentPage
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .dismissedOnboarding, extras: ["slide-num": currentPage])
        
        if #available(iOS 14, *) {
            self.scrollView.isHidden = true
            self.pageControl.isHidden = true
            self.defaultBrowserView.isHidden = false
            self.closeButton.isHidden = true
        } else {
            self.didFinishClosure?(self, nil)
        }
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
        let page : Int = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        pageControl.currentPage = page
    }
}
