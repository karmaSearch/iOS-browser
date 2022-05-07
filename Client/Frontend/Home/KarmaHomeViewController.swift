/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import UIKit
import Storage
import SDWebImage
import XCGLogger
import SyncTelemetry

private let log = Logger.browserLogger

// MARK: -  UX

struct FirefoxHomeUX {
    static let highlightCellHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 250 : 200
    static let jumpBackInCellHeight: CGFloat = 120
    static let karmaMenuHeight: CGFloat = 60
    static let recentlySavedCellHeight: CGFloat = 136
    static let sectionInsetsForSizeClass = UXSizeClasses(compact: 0, regular: 101, other: 15)
    static let numberOfItemsPerRowForSizeClassIpad = UXSizeClasses(compact: 3, regular: 4, other: 2)
    static let spacingBetweenSections: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 24 : 0
    static let sectionInsetsForIpad: CGFloat = 101
    static let minimumInsets: CGFloat = 20
    static let libraryShortcutsHeight: CGFloat = 90
    static let libraryShortcutsMaxWidth: CGFloat = 375
    static let customizeHomeHeight: CGFloat = 100
    static let learnAndActHeight: CGFloat = 159
}

struct FxHomeAccessibilityIdentifiers {
    struct MoreButtons {
        static let recentlySaved = "recentlySavedSectionMoreButton"
        static let jumpBackIn = "jumpBackInSectionMoreButton"
    }

    struct SectionTitles {
        static let jumpBackIn = "jumpBackInTitle"
        static let recentlySaved = "jumpBackInTitle"
        static let pocket = "pocketTitle"
        static let library = "libraryTitle"
        static let topSites = "topSitesTitle"
    }
}

struct FxHomeDevStrings {
    struct GestureRecognizers {
        static let dismissOverlay = "dismissOverlay"
    }
}


/*
 Size classes are the way Apple requires us to specify our UI.
 Split view on iPad can make a landscape app appear with the demensions of an iPhone app
 Use UXSizeClasses to specify things like offsets/itemsizes with respect to size classes
 For a primer on size classes https://useyourloaf.com/blog/size-classes/
 */
struct UXSizeClasses {
    var compact: CGFloat
    var regular: CGFloat
    var unspecified: CGFloat

    init(compact: CGFloat, regular: CGFloat, other: CGFloat) {
        self.compact = compact
        self.regular = regular
        self.unspecified = other
    }

    subscript(sizeClass: UIUserInterfaceSizeClass) -> CGFloat {
        switch sizeClass {
            case .compact:
                return self.compact
            case .regular:
                return self.regular
            case .unspecified:
                return self.unspecified
            @unknown default:
                fatalError()
        }

    }
}

// MARK: - Home Panel

protocol HomePanelDelegate: AnyObject {
    func homePanelDidRequestToOpenInNewTab(_ url: URL, isPrivate: Bool)
    func homePanel(didSelectURL url: URL, visitType: VisitType, isGoogleTopSite: Bool)
    func homePanelDidRequestToOpenLibrary(panel: LibraryPanelType)
    func homePanelDidRequestToOpenTabTray(withFocusedTab tabToFocus: Tab?)
    func homePanelDidRequestToCustomizeHomeSettings()
    func homePanelDidPresentContextualHint(type: ContextualHintViewType)
    func homePanelDidDismissContextualHint(type: ContextualHintViewType)
    func homePanelDidRequestToOpenSettings(caller: UIButton)
}

protocol HomePanel: NotificationThemeable {
    var homePanelDelegate: HomePanelDelegate? { get set }
}

enum HomePanelType: Int {
    case topSites = 0

    var internalUrl: URL {
        let aboutUrl: URL! = URL(string: "\(InternalURL.baseUrl)/\(AboutHomeHandler.path)")
        return URL(string: "#panel=\(self.rawValue)", relativeTo: aboutUrl)!
    }
}

protocol HomePanelContextMenu {
    func getSiteDetails(for indexPath: IndexPath) -> Site?
    func getContextMenuActions(for site: Site, with indexPath: IndexPath) -> [PhotonActionSheetItem]?
    func presentContextMenu(for indexPath: IndexPath)
    func presentContextMenu(for site: Site, with indexPath: IndexPath, completionHandler: @escaping () -> PhotonActionSheet?)
}

extension HomePanelContextMenu {
    func presentContextMenu(for indexPath: IndexPath) {
        guard let site = getSiteDetails(for: indexPath) else { return }

        presentContextMenu(for: site, with: indexPath, completionHandler: {
            return self.contextMenu(for: site, with: indexPath)
        })
    }

    func contextMenu(for site: Site, with indexPath: IndexPath) -> PhotonActionSheet? {
        guard let actions = self.getContextMenuActions(for: site, with: indexPath) else { return nil }

        let contextMenu = PhotonActionSheet(site: site, actions: actions)
        contextMenu.modalPresentationStyle = .overFullScreen
        contextMenu.modalTransitionStyle = .crossDissolve

        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        return contextMenu
    }

    func getDefaultContextMenuActions(for site: Site, homePanelDelegate: HomePanelDelegate?) -> [PhotonActionSheetItem]? {
        guard let siteURL = URL(string: site.url) else { return nil }

        let openInNewTabAction = PhotonActionSheetItem(title: .OpenInNewTabContextMenuTitle, iconString: "quick_action_new_tab") { _, _ in
            homePanelDelegate?.homePanelDidRequestToOpenInNewTab(siteURL, isPrivate: false)
        }

        let openInNewPrivateTabAction = PhotonActionSheetItem(title: .OpenInNewPrivateTabContextMenuTitle, iconString: "quick_action_new_private_tab") { _, _ in
            homePanelDelegate?.homePanelDidRequestToOpenInNewTab(siteURL, isPrivate: true)
        }

        return [openInNewTabAction, openInNewPrivateTabAction]
    }
}

// MARK: - HomeVC

class KarmaHomeViewController: UICollectionViewController, HomePanel, FeatureFlagsProtocol {
    weak var homePanelDelegate: HomePanelDelegate?
    weak var libraryPanelDelegate: LibraryPanelDelegate?
    fileprivate var hasPresentedContextualHint = false
    fileprivate var didRotate = false
    fileprivate let profile: Profile
    fileprivate let pocketAPI = Pocket()
    fileprivate let flowLayout = UICollectionViewFlowLayout()
    fileprivate var hasSentPocketSectionEvent = false
    fileprivate var hasSentJumpBackInSectionEvent = false
    fileprivate var timer: Timer?
    fileprivate var contextualSourceView = UIView()
    var recentlySavedViewModel = FirefoxHomeRecentlySavedViewModel()
    var jumpBackInViewModel = FirefoxHomeJumpBackInViewModel()

    fileprivate lazy var topSitesManager: ASHorizontalScrollCellManager = {
        let manager = ASHorizontalScrollCellManager()
        return manager
    }()

    var contextualHintViewController = ContextualHintViewController(hintType: .jumpBackIn)

    lazy var overlayView: UIView = .build { [weak self] overlayView in
        overlayView.backgroundColor = UIColor.Photon.Grey90A10
        overlayView.isHidden = true
    }

    fileprivate lazy var longPressRecognizer: UILongPressGestureRecognizer = {
        return UILongPressGestureRecognizer(target: self, action: #selector(longPress))
    }()

    private var tapGestureRecognizer: UITapGestureRecognizer {
        let dismissOverlay = UITapGestureRecognizer(target: self, action: #selector(dismissOverlayMode))
        dismissOverlay.name = FxHomeDevStrings.GestureRecognizers.dismissOverlay
        dismissOverlay.cancelsTouchesInView = false
        return dismissOverlay
    }

    // Not used for displaying. Only used for calculating layout.
    lazy var topSiteCell: ASHorizontalScrollCell = {
        let customCell = ASHorizontalScrollCell(frame: CGRect(width: self.view.frame.size.width, height: 0))
        customCell.delegate = self.topSitesManager
        return customCell
    }()
    
    // Not used for displaying. Only used for calculating layout.
    lazy var learnAndActCell: LearnAndActViewCell = {
        let customCell = LearnAndActViewCell(frame: CGRect(width: self.view.frame.size.width, height: 0))
        return customCell
    }()
    
    var pocketStories: [PocketStory] = []
    var learnAndAct: LearnAndAct?
    var hasRecentBookmarks = false
    var hasReadingListitems = false
    var currentTab: Tab? {
        let tabManager = BrowserViewController.foregroundBVC().tabManager
        return tabManager.selectedTab
    }

    var sectionsEnabled: [Homescreen.SectionId: Bool] = [:]

    // MARK: - Section availability variables
    var isTopSitesSectionEnabled: Bool {
        sectionsEnabled[.topSites] == true
    }
    
    var isKarmaHomeSectionEnabled: Bool {
        sectionsEnabled[.karmahome] == true
    }
    
    var isLearnAndActSectionEnabled: Bool {
        sectionsEnabled[.learnandact] == true
    }
    
    var isYourLibrarySectionEnabled: Bool {
        UIDevice.current.userInterfaceIdiom != .pad &&
        sectionsEnabled[.libraryShortcuts] == true
    }

    var isJumpBackInSectionEnabled: Bool {
        guard featureFlags.isFeatureActiveForBuild(.jumpBackIn),
              sectionsEnabled[.jumpBackIn] == true,
              featureFlags.userPreferenceFor(.jumpBackIn) == UserFeaturePreference.enabled
        else { return false }

        let tabManager = BrowserViewController.foregroundBVC().tabManager
        return !(tabManager.selectedTab?.isPrivate ?? false)
            && !tabManager.recentlyAccessedNormalTabs.isEmpty
    }

    var isRecentlySavedSectionEnabled: Bool {
        guard featureFlags.isFeatureActiveForBuild(.recentlySaved),
              sectionsEnabled[.recentlySaved] == true,
              featureFlags.userPreferenceFor(.recentlySaved) == UserFeaturePreference.enabled
        else { return false }

        return hasRecentBookmarks || hasReadingListitems
    }

    var isPocketSectionEnabled: Bool {
        // For Pocket, the user preference check returns a user preference if it exists in
        // UserDefaults, and, if it does not, it will return a default preference based on
        // a (nimbus pocket section enabled && Pocket.isLocaleSupported) check
        guard featureFlags.isFeatureActiveForBuild(.pocket),
              featureFlags.userPreferenceFor(.pocket) == UserFeaturePreference.enabled
        else { return false }

        return true
    }
    
    private let learnAndActViewModel = LearnAndActViewModel()

    // MARK: - Initializers
    init(profile: Profile) {
        self.profile = profile
        super.init(collectionViewLayout: flowLayout)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        flowLayout.minimumLineSpacing = 25
        
        collectionView?.addGestureRecognizer(longPressRecognizer)
        currentTab?.lastKnownUrl?.absoluteString.hasPrefix("internal://") ?? false ? collectionView?.addGestureRecognizer(tapGestureRecognizer) : nil
        
        let refreshEvents: [Notification.Name] = [.DynamicFontChanged, .HomePanelPrefsChanged, .DisplayThemeChanged]
        refreshEvents.forEach { NotificationCenter.default.addObserver(self, selector: #selector(reload), name: $0, object: nil) }
        let homeScren = Homescreen()
        self.sectionsEnabled = homeScren.fullSectionsEnabled
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        Section.allCases.forEach { collectionView.register($0.cellType, forCellWithReuseIdentifier: $0.cellIdentifier) }
        self.collectionView?.register(ASHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        self.collectionView?.register(LearnAndActHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "LearnAndActHeader")
        collectionView?.keyboardDismissMode = .onDrag
        collectionView?.backgroundColor = .clear
        self.view.addSubviews(overlayView)
        self.view.addSubview(contextualSourceView)
        contextualSourceView.backgroundColor = .clear

        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        self.view.backgroundColor = UIColor.theme.homePanel.topSitesBackground
        self.profile.panelDataObservers.activityStream.delegate = self

        
        applyTheme()
        
        learnAndActViewModel.getDatas { [weak self] learnAndAct in
            self?.learnAndAct = learnAndAct
            self?.collectionView.reloadSections(IndexSet(integer: Section.learnAndAct.rawValue))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadAll()
    }

    override func viewDidAppear(_ animated: Bool) {
        TelemetryWrapper.recordEvent(category: .action,
                                     method: .view,
                                     object: .firefoxHomepage,
                                     value: .fxHomepageOrigin)

        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: {context in
            // The AS context menu does not behave correctly. Dismiss it when rotating.
            if let _ = self.presentedViewController as? PhotonActionSheet {
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            }
            self.collectionViewLayout.invalidateLayout()
            self.reloadAll()

            self.collectionView?.reloadData()
        }, completion: { _ in
            if !self.didRotate { self.didRotate = true }
            // Workaround: label positions are not correct without additional reload
            self.collectionView?.reloadData()
        })
    }

    // MARK: - Helpers
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.topSitesManager.currentTraits = self.traitCollection
        applyTheme()
    }
    @objc func reload(notification: Notification) {
        reloadAll()
    }

    func applyTheme() {
        self.view.backgroundColor = UIColor.theme.homePanel.topSitesBackground
        topSiteCell.collectionView.reloadData()
        if let collectionView = self.collectionView, collectionView.numberOfSections > 0 {
            collectionView.reloadData()
        }
    }
    
    func reduceSection() {
        let reduceSectionsEnabled = Homescreen().reduceSectionsEnabled
        guard sectionsEnabled != reduceSectionsEnabled else { return }
        sectionsEnabled = reduceSectionsEnabled
        if let collectionView = self.collectionView{
            collectionView.reloadData()
        }
        reloadAll()
    }
    
    func expandSection() {
        if let gestureRecognizers = collectionView.gestureRecognizers {
            for (index, gesture) in gestureRecognizers.enumerated() {
                if gesture.name == FxHomeDevStrings.GestureRecognizers.dismissOverlay {
                    collectionView.gestureRecognizers?.remove(at: index)
                }
            }
        }
        let fullSectionsEnabled = Homescreen().fullSectionsEnabled
        guard sectionsEnabled != fullSectionsEnabled else { return }
        sectionsEnabled = fullSectionsEnabled
        if let collectionView = self.collectionView{
            collectionView.reloadData()
        }
        reloadAll()
    }

    func scrollToTop(animated: Bool = false) {
        collectionView?.setContentOffset(.zero, animated: animated)
    }

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        currentTab?.lastKnownUrl?.absoluteString.hasPrefix("internal://") ?? false ? BrowserViewController.foregroundBVC().urlBar.leaveOverlayMode() : nil
    }

    @objc func dismissOverlayMode() {
        BrowserViewController.foregroundBVC().urlBar.leaveOverlayMode()
        if let gestureRecognizers = collectionView.gestureRecognizers {
            for (index, gesture) in gestureRecognizers.enumerated() {
                if gesture.name == FxHomeDevStrings.GestureRecognizers.dismissOverlay {
                    collectionView.gestureRecognizers?.remove(at: index)
                }
            }
        }
    }

    func configureItemsForRecentlySaved() {
        profile.places.getRecentBookmarks(limit: 5).uponQueue(.main) { [weak self] result in
            self?.hasRecentBookmarks = false

            if let bookmarks = result.successValue,
               !bookmarks.isEmpty,
               !RecentItemsHelper.filterStaleItems(recentItems: bookmarks, since: Date()).isEmpty {
                self?.hasRecentBookmarks = true

                TelemetryWrapper.recordEvent(category: .action,
                                             method: .view,
                                             object: .firefoxHomepage,
                                             value: .recentlySavedBookmarkItemView,
                                             extras: [TelemetryWrapper.EventObject.recentlySavedBookmarkImpressions.rawValue: bookmarks.count])
            }

            self?.collectionView.reloadData()
        }

        if let readingList = profile.readingList.getAvailableRecords().value.successValue?.prefix(RecentlySavedCollectionCellUX.readingListItemsLimit) {
            var readingListItems = Array(readingList)
            readingListItems = RecentItemsHelper.filterStaleItems(recentItems: readingListItems,
                                                                       since: Date()) as! [ReadingListItem]
            self.hasReadingListitems = !readingListItems.isEmpty

            TelemetryWrapper.recordEvent(category: .action,
                                         method: .view,
                                         object: .firefoxHomepage,
                                         value: .recentlySavedBookmarkItemView,
                                         extras: [TelemetryWrapper.EventObject.recentlySavedReadingItemImpressions.rawValue: readingListItems.count])

            self.collectionView.reloadData()
        }

    }

    func presentContextualHint() {
        overlayView.isHidden = false
        hasPresentedContextualHint = true

        let contentSize = CGSize(width: 325, height: contextualHintViewController.heightForDescriptionLabel)
        contextualHintViewController.preferredContentSize = contentSize
        contextualHintViewController.modalPresentationStyle = .popover

        if let popoverPresentationController = contextualHintViewController.popoverPresentationController {
            popoverPresentationController.sourceView = contextualSourceView
            popoverPresentationController.sourceRect = contextualSourceView.bounds
            popoverPresentationController.permittedArrowDirections = .down
            popoverPresentationController.delegate = self
        }

        contextualHintViewController.onViewDismissed = { [weak self] in
            self?.overlayView.isHidden = true
            self?.homePanelDelegate?.homePanelDidDismissContextualHint(type: .jumpBackIn)
        }

        contextualHintViewController.viewModel.markContextualHintPresented(profile: profile)
        homePanelDelegate?.homePanelDidPresentContextualHint(type: .jumpBackIn)
        present(contextualHintViewController, animated: true, completion: nil)
    }

    func contextualHintPresentTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.25, target: self, selector: #selector(presentContextualOverlay), userInfo: nil, repeats: false)
    }

    @objc func presentContextualOverlay() {
        presentContextualHint()
    }

    private func getHeaderSize(forSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        let size = CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height)

        return headerView.systemLayoutSizeFitting(size,
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
}

// MARK: -  Section Management

extension KarmaHomeViewController {

    enum Section: Int, CaseIterable {
        case karmaMenu
        case topSites
        case libraryShortcuts
        case jumpBackIn
        case recentlySaved
        case pocket
        case customizeHome
        case learnAndAct

        var title: String? {
            switch self {
            case .karmaMenu: return nil
            case .pocket: return .ASPocketTitle2
            case .jumpBackIn: return .FirefoxHomeJumpBackInSectionTitle
            case .recentlySaved: return .RecentlySavedSectionTitle
            case .topSites: return .ASShortcutsTitle
            case .libraryShortcuts: return .AppMenuLibraryTitleString
            case .customizeHome: return nil
            case .learnAndAct: return nil
            }
        }

        var headerImage: UIImage? {
            switch self {
            case .pocket: return UIImage.templateImageNamed("menu-pocket")
            case .topSites: return UIImage.templateImageNamed("menu-panel-TopSites")
            case .libraryShortcuts: return UIImage.templateImageNamed("menu-library")
            default : return nil
            }
        }

        var footerHeight: CGSize {
            switch self {
            case .pocket, .jumpBackIn, .recentlySaved, .customizeHome, .karmaMenu, .learnAndAct: return .zero
            case .topSites, .libraryShortcuts: return CGSize(width: 50, height: 5)
            }
        }

        func cellHeight(_ traits: UITraitCollection, width: CGFloat) -> CGFloat {
            switch self {
            case .karmaMenu: return FirefoxHomeUX.karmaMenuHeight
            case .pocket: return FirefoxHomeUX.highlightCellHeight
            case .jumpBackIn: return FirefoxHomeUX.jumpBackInCellHeight
            case .recentlySaved: return FirefoxHomeUX.recentlySavedCellHeight
            case .topSites: return 0 //calculated dynamically
            case .libraryShortcuts: return FirefoxHomeUX.libraryShortcutsHeight
            case .customizeHome: return FirefoxHomeUX.customizeHomeHeight
            case .learnAndAct: return 0 //calculated dynamically
            }
        }

        /*
         There are edge cases to handle when calculating section insets
        - An iPhone 7+ is considered regular width when in landscape
        - An iPad in 66% split view is still considered regular width
         */
        func sectionInsets(_ traits: UITraitCollection, frameWidth: CGFloat) -> CGFloat {
            var currentTraits = traits
            if (traits.horizontalSizeClass == .regular && UIScreen.main.bounds.size.width != frameWidth) || UIDevice.current.userInterfaceIdiom == .phone {
                currentTraits = UITraitCollection(horizontalSizeClass: .compact)
            }
            var insets = FirefoxHomeUX.sectionInsetsForSizeClass[currentTraits.horizontalSizeClass]
            let window = UIApplication.shared.windows.first
            let safeAreaInsets = window?.safeAreaInsets.left ?? 0
            insets += FirefoxHomeUX.minimumInsets + safeAreaInsets
            return insets
        }

        func numberOfItemsForRow(_ traits: UITraitCollection) -> CGFloat {
            switch self {
            case .pocket:
                var numItems: CGFloat = FirefoxHomeUX.numberOfItemsPerRowForSizeClassIpad[traits.horizontalSizeClass]
                if !UIWindow.isLandscape {
                    numItems = numItems - 1
                }
                if traits.horizontalSizeClass == .compact && UIWindow.isLandscape {
                    numItems = numItems - 1
                }

                return numItems
            case .topSites, .libraryShortcuts, .jumpBackIn, .recentlySaved, .customizeHome, .learnAndAct, .karmaMenu:
                return 1
            }
        }

        func cellSize(for traits: UITraitCollection, frameWidth: CGFloat) -> CGSize {
            let height = cellHeight(traits, width: frameWidth)
            let inset = sectionInsets(traits, frameWidth: frameWidth) * 2

            switch self {
            case .pocket:
                let numItems = numberOfItemsForRow(traits)
                return CGSize(width: floor(((frameWidth - inset) - (FirefoxHomeUX.minimumInsets * (numItems - 1))) / numItems), height: height)
            case .topSites, .libraryShortcuts, .jumpBackIn, .recentlySaved, .customizeHome, .learnAndAct:
                return CGSize(width: frameWidth - inset, height: height)
            case .karmaMenu:
                return CGSize(width: frameWidth, height: height)
            }
        }

        var cellIdentifier: String {
            switch self {
            case .karmaMenu: return "KarmaMenuCell"
            case .topSites: return "TopSiteCell"
            case .pocket: return "PocketCell"
            case .jumpBackIn: return "JumpBackInCell"
            case .recentlySaved: return "RecentlySavedCell"
            case .libraryShortcuts: return  "LibraryShortcutsCell"
            case .customizeHome: return "CustomizeHomeCell"
            case .learnAndAct: return "LearnAndActViewCell"
            }
        }

        var cellType: UICollectionViewCell.Type {
            switch self {
            case .karmaMenu: return KarmaHomeViewCell.self
            case .topSites: return ASHorizontalScrollCell.self
            case .pocket: return FirefoxHomeHighlightCell.self
            case .jumpBackIn: return FxHomeJumpBackInCollectionCell.self
            case .recentlySaved: return FxHomeRecentlySavedCollectionCell.self
            case .libraryShortcuts: return ASLibraryCell.self
            case .customizeHome: return FxHomeCustomizeHomeView.self
            case .learnAndAct: return LearnAndActViewCell.self
            }
        }

        init(at indexPath: IndexPath) {
            self.init(rawValue: indexPath.section)!
        }

        init(_ section: Int) {
            self.init(rawValue: section)!
        }
    }
}

// MARK: -  CollectionView Delegate

extension KarmaHomeViewController: UICollectionViewDelegateFlowLayout {

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            if Section(indexPath.section) == .learnAndAct {
                let learnAndActHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "LearnAndActHeader", for: indexPath) as! LearnAndActHeader
                return learnAndActHeader
            }
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! ASHeaderView
            let title = Section(indexPath.section).title
            headerView.title = title

            switch Section(indexPath.section) {
            case .pocket:
                // tracking pocket section shown
                if !hasSentPocketSectionEvent {
                    TelemetryWrapper.recordEvent(category: .action, method: .view, object: .pocketSectionImpression, value: nil, extras: nil)
                    hasSentPocketSectionEvent = true
                }
                headerView.moreButton.isHidden = false
                headerView.moreButton.setTitle(.PocketMoreStoriesText, for: .normal)
                headerView.moreButton.addTarget(self, action: #selector(showMorePocketStories), for: .touchUpInside)
                headerView.titleLabel.accessibilityIdentifier = FxHomeAccessibilityIdentifiers.SectionTitles.pocket
                return headerView

            case .jumpBackIn:
                if !hasSentJumpBackInSectionEvent
                    && isJumpBackInSectionEnabled
                    && !(jumpBackInViewModel.jumpList.itemsToDisplay == 0) {
                    TelemetryWrapper.recordEvent(category: .action, method: .view, object: .jumpBackInImpressions, value: nil, extras: nil)
                    hasSentJumpBackInSectionEvent = true
                }
                headerView.moreButton.isHidden = false
                headerView.moreButton.setTitle(.RecentlySavedShowAllText, for: .normal)
                headerView.moreButton.addTarget(self, action: #selector(openTabTray), for: .touchUpInside)
                headerView.moreButton.accessibilityIdentifier = FxHomeAccessibilityIdentifiers.MoreButtons.jumpBackIn
                headerView.titleLabel.accessibilityIdentifier = FxHomeAccessibilityIdentifiers.SectionTitles.jumpBackIn
                let attributes = collectionView.layoutAttributesForItem(at: indexPath)
                    if let frame = attributes?.frame, headerView.convert(frame, from: collectionView).height > 1 {
                        // Using a timer for the first presentation of contextual hint due to many reloads that happen on the collection view. Invalidating the timer prevents from showing contextual hint at the wrong position.
                        timer?.invalidate()
                        if didRotate && hasPresentedContextualHint {
                            contextualSourceView = headerView.titleLabel
                            didRotate = false
                        } else if !hasPresentedContextualHint && contextualHintViewController.viewModel.shouldPresentContextualHint(profile: profile) {
                            contextualSourceView = headerView.titleLabel
                            contextualHintPresentTimer()
                        }
                }
                return headerView
            case .recentlySaved:
                headerView.moreButton.isHidden = false
                headerView.moreButton.setTitle(.RecentlySavedShowAllText, for: .normal)
                headerView.moreButton.addTarget(self, action: #selector(openBookmarks), for: .touchUpInside)
                headerView.moreButton.accessibilityIdentifier = FxHomeAccessibilityIdentifiers.MoreButtons.recentlySaved
                headerView.titleLabel.accessibilityIdentifier = FxHomeAccessibilityIdentifiers.SectionTitles.recentlySaved
                return headerView

            case .topSites:
                headerView.titleLabel.accessibilityIdentifier = FxHomeAccessibilityIdentifiers.SectionTitles.topSites
                headerView.moreButton.isHidden = true
                return headerView
            case .libraryShortcuts:
                headerView.moreButton.isHidden = true
                headerView.titleLabel.accessibilityIdentifier = FxHomeAccessibilityIdentifiers.SectionTitles.library
                return headerView
            default:
                return UICollectionReusableView()
            }
        default:
            return UICollectionReusableView()
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.longPressRecognizer.isEnabled = false
        selectItemAtIndex(indexPath.item, inSection: Section(indexPath.section))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellSize = Section(indexPath.section).cellSize(for: self.traitCollection, frameWidth: self.view.frame.width)

        switch Section(indexPath.section) {
        case .topSites:
            // Create a temporary cell so we can calculate the height.
            let layout = topSiteCell.collectionView.collectionViewLayout as! HorizontalFlowLayout
            let estimatedLayout = layout.calculateLayout(for: CGSize(width: cellSize.width, height: 0))
            return CGSize(width: cellSize.width, height: estimatedLayout.size.height)
        case .jumpBackIn:
            if jumpBackInViewModel.layoutVariables.scrollDirection == .horizontal {
                if jumpBackInViewModel.jumpList.itemsToDisplay > 2 {
                    cellSize.height *= 2
                }
            } else if jumpBackInViewModel.layoutVariables.scrollDirection == .vertical {
                cellSize.height *= CGFloat(jumpBackInViewModel.jumpList.itemsToDisplay)
            }
            return cellSize
        case .libraryShortcuts:
            let width = min(FirefoxHomeUX.libraryShortcutsMaxWidth, cellSize.width)
            return CGSize(width: width, height: cellSize.height)
        case .learnAndAct:
            guard let learnAndAct = self.learnAndAct?.blocs, !learnAndAct.isEmpty else { return cellSize }
            learnAndActCell.learnAndAct = learnAndAct[indexPath.row]
            let height = learnAndActCell.calculateSize(width: cellSize.width)
            return CGSize(width: cellSize.width, height: height)
        case .customizeHome, .pocket, .recentlySaved, .karmaMenu:
            return cellSize

        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        switch Section(section) {
        case .pocket:
            return pocketStories.isEmpty ? .zero : getHeaderSize(forSection: section)
        case .topSites:
            return isTopSitesSectionEnabled ? getHeaderSize(forSection: section) : .zero
        case .libraryShortcuts:
            return isYourLibrarySectionEnabled ? getHeaderSize(forSection: section) : .zero
        case .jumpBackIn:
            return isJumpBackInSectionEnabled ? getHeaderSize(forSection: section) : .zero
        case .recentlySaved:
            return isRecentlySavedSectionEnabled ? getHeaderSize(forSection: section) : .zero
        case .learnAndAct:
            return isLearnAndActSectionEnabled ? getHeaderSize(forSection: section) : .zero
        case .customizeHome, .karmaMenu:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = Section(section).sectionInsets(self.traitCollection, frameWidth: self.view.frame.width)
        let defaultInsets =  UIEdgeInsets(top: 0, left: insets, bottom: FirefoxHomeUX.spacingBetweenSections, right: insets)
        
        switch Section(section) {
        case .pocket:
            return pocketStories.isEmpty ? .zero : defaultInsets
        case .topSites:
            let topSitesInset =  UIEdgeInsets(top: 0, left: insets, bottom: FirefoxHomeUX.spacingBetweenSections+55, right: insets)
            return isTopSitesSectionEnabled ? topSitesInset : .zero
        case .libraryShortcuts:
            return isYourLibrarySectionEnabled ? defaultInsets : .zero
        case .jumpBackIn:
            return isJumpBackInSectionEnabled ? defaultInsets : .zero
        case .recentlySaved:
            return isRecentlySavedSectionEnabled ? defaultInsets : .zero
        case .learnAndAct:
            return isLearnAndActSectionEnabled ? defaultInsets : .zero
        case .customizeHome:
            return isLearnAndActSectionEnabled ? defaultInsets : .zero
        case .karmaMenu:
            return isKarmaHomeSectionEnabled ? defaultInsets : .zero
        }
        
    }

    fileprivate func showSiteWithURLHandler(_ url: URL, isGoogleTopSite: Bool = false) {
        let visitType = VisitType.bookmark
        homePanelDelegate?.homePanel(didSelectURL: url, visitType: visitType, isGoogleTopSite: isGoogleTopSite)
    }
}

// MARK: - CollectionView Data Source

extension KarmaHomeViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numItems: CGFloat = FirefoxHomeUX.numberOfItemsPerRowForSizeClassIpad[self.traitCollection.horizontalSizeClass]
        if !UIWindow.isLandscape {
            numItems = numItems - 1
        }
        if self.traitCollection.horizontalSizeClass == .compact && UIWindow.isLandscape {
            numItems = numItems - 1
        }

        switch Section(section) {
        case .topSites:
            return isTopSitesSectionEnabled && !topSitesManager.content.isEmpty ? 1 : 0
        case .pocket:
            // There should always be a full row of pocket stories (numItems) otherwise don't show them
            return pocketStories.count
        case .jumpBackIn:
            return isJumpBackInSectionEnabled ? 1 : 0
        case .recentlySaved:
            return isRecentlySavedSectionEnabled ? 1 : 0
        case .libraryShortcuts:
            return isYourLibrarySectionEnabled ? 1 : 0
        case .karmaMenu:
            return isKarmaHomeSectionEnabled ? 1 : 0
        case .customizeHome:
            return 0
        case .learnAndAct:
            return isLearnAndActSectionEnabled ? (learnAndAct?.blocs.count ?? 0 ): 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = Section(indexPath.section).cellIdentifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)

        switch Section(indexPath.section) {
        case .topSites:
            return configureTopSitesCell(cell, forIndexPath: indexPath)
        case .pocket:
            return configurePocketItemCell(cell, forIndexPath: indexPath)
        case .jumpBackIn:
            return configureJumpBackInCell(cell, forIndexPath: indexPath)
        case .recentlySaved:
            return configureRecentlySavedCell(cell, forIndexPath: indexPath)
        case .libraryShortcuts:
            return configureLibraryShortcutsCell(cell, forIndexPath: indexPath)
        case .customizeHome:
            return configureCustomizeHomeCell(cell, forIndexPath: indexPath)
        case .karmaMenu:
            return configureCustomizeKarmaCell(cell, forIndexPath: indexPath)
        case .learnAndAct:
            return configureCustomizeLearnAndActCell(cell, forIndexPath: indexPath)
        }
    }

    func configureLibraryShortcutsCell(_ cell: UICollectionViewCell, forIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let libraryCell = cell as! ASLibraryCell
        let targets = [#selector(openBookmarks), #selector(openHistory), #selector(openDownloads), #selector(openReadingList)]
        libraryCell.libraryButtons.map({ $0.button }).zip(targets).forEach { (button, selector) in
            button.removeTarget(nil, action: nil, for: .allEvents)
            button.addTarget(self, action: selector, for: .touchUpInside)
        }
        libraryCell.applyTheme()

        return cell
    }

    func configureTopSitesCell(_ cell: UICollectionViewCell, forIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let topSiteCell = cell as! ASHorizontalScrollCell
        topSiteCell.delegate = self.topSitesManager
        topSiteCell.setNeedsLayout()
        topSiteCell.collectionView.reloadData()
        return cell
    }

    func configurePocketItemCell(_ cell: UICollectionViewCell, forIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let pocketStory = pocketStories[indexPath.row]
        let pocketItemCell = cell as! FirefoxHomeHighlightCell
        pocketItemCell.configureWithPocketStory(pocketStory)

        return pocketItemCell
    }

    private func configureRecentlySavedCell(_ cell: UICollectionViewCell, forIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let recentlySavedCell = cell as! FxHomeRecentlySavedCollectionCell
        recentlySavedCell.homePanelDelegate = homePanelDelegate
        recentlySavedCell.libraryPanelDelegate = libraryPanelDelegate
        recentlySavedCell.profile = profile
        recentlySavedCell.collectionView.reloadData()
        recentlySavedCell.setNeedsLayout()
        recentlySavedCell.viewModel = recentlySavedViewModel

        return recentlySavedCell
    }

    private func configureJumpBackInCell(_ cell: UICollectionViewCell, forIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let jumpBackInCell = cell as! FxHomeJumpBackInCollectionCell
        jumpBackInCell.profile = profile

        jumpBackInViewModel.onTapGroup = { [weak self] tab in
            self?.homePanelDelegate?.homePanelDidRequestToOpenTabTray(withFocusedTab: tab)
        }

        jumpBackInCell.viewModel = jumpBackInViewModel
        jumpBackInCell.collectionView.reloadData()
        jumpBackInCell.setNeedsLayout()

        return jumpBackInCell
    }

    private func configureCustomizeHomeCell(_ cell: UICollectionViewCell, forIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let customizeHomeCell = cell as! FxHomeCustomizeHomeView
        customizeHomeCell.goToSettingsButton.addTarget(self, action: #selector(openCustomizeHomeSettings), for: .touchUpInside)
        customizeHomeCell.setNeedsLayout()

        return customizeHomeCell
    }
    
    private func configureCustomizeKarmaCell(_ cell: UICollectionViewCell, forIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let customizeHomeCell = cell as! KarmaHomeViewCell
        customizeHomeCell.setNeedsLayout()
        customizeHomeCell.openMenu = { [weak self] button in
            self?.homePanelDelegate?.homePanelDidRequestToOpenSettings(caller: button)
        }
        customizeHomeCell.applyTheme()
        return customizeHomeCell
    }
    
    private func configureCustomizeLearnAndActCell(_ cell: UICollectionViewCell, forIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let customizeCell = cell as! LearnAndActViewCell
        customizeCell.learnAndAct = self.learnAndAct?.blocs[indexPath.row]
        customizeCell.setNeedsLayout()
        customizeCell.addShadow()
        return customizeCell
    }
    
}

// MARK: - Data Management

extension KarmaHomeViewController: DataObserverDelegate {

    // Reloads both highlights and top sites data from their respective caches. Does not invalidate the cache.
    // See ActivityStreamDataObserver for invalidation logic.
    func reloadAll() {
        // Overlay view is used by contextual hint and reloading the view while the hint is shown can cause the popover to flicker
        guard overlayView.isHidden else { return }

        // If the pocket stories are not availible for the Locale the PocketAPI will return nil
        // So it is okay if the default here is true

        self.configureItemsForRecentlySaved()

        TopSitesHandler.getTopSites(profile: profile).uponQueue(.main) { [weak self] result in
            guard let self = self else { return }

            // If there is no pending cache update and highlights are empty. Show the onboarding screen
            self.collectionView?.reloadData()

            self.topSitesManager.currentTraits = self.view.traitCollection

            let numRows = max(self.profile.prefs.intForKey(PrefsKeys.NumberOfTopSiteRows) ?? TopSitesRowCountSettingsController.defaultNumberOfRows, 1)
            
            let fullSectionsEnabled = Homescreen().fullSectionsEnabled
            
            let numLines = self.sectionsEnabled == fullSectionsEnabled ? 1 : 2
            let maxItems = Int(numRows) * self.topSitesManager.numberOfHorizontalItems() * numLines
            
            let sites = Array(result.prefix(maxItems))

            // Check if all result items are pinned site
            var pinnedSites = 0
            result.forEach {
                if let _ = $0 as? PinnedSite {
                    pinnedSites += 1
                }
            }
            self.topSitesManager.content = sites
            self.topSitesManager.urlPressedHandler = { [unowned self] site, indexPath in
                self.longPressRecognizer.isEnabled = false
                guard let url = site.url.asURL else { return }
                let isGoogleTopSiteUrl = url.absoluteString == GoogleTopSiteConstants.usUrl || url.absoluteString == GoogleTopSiteConstants.rowUrl
                self.topSiteTracking(site: site, position: indexPath.item)
                self.showSiteWithURLHandler(url as URL, isGoogleTopSite: isGoogleTopSiteUrl)
            }

            self.getPocketSites().uponQueue(.main) { _ in
                if !self.pocketStories.isEmpty {
                    self.collectionView?.reloadData()
                }
            }
            // Refresh the AS data in the background so we'll have fresh data next time we show.
            self.profile.panelDataObservers.activityStream.refreshIfNeeded(forceTopSites: false)
        }
    }

    func topSiteTracking(site: Site, position: Int) {
        let topSitePositionKey = TelemetryWrapper.EventExtraKey.topSitePosition.rawValue
        let topSiteTileTypeKey = TelemetryWrapper.EventExtraKey.topSiteTileType.rawValue
        let isPinnedAndGoogle = site is PinnedSite && site.guid == GoogleTopSiteConstants.googleGUID
        let isPinnedOnly = site is PinnedSite
        let isSuggestedSite = site is SuggestedSite
        let type = isPinnedAndGoogle ? "google" : isPinnedOnly ? "user-added" : isSuggestedSite ? "suggested" : "history-based"
        TelemetryWrapper.recordEvent(category: .action, method: .tap, object: .topSiteTile, value: nil, extras: [topSitePositionKey : "\(position)", topSiteTileTypeKey: type])
    }

    func getPocketSites() -> Success {

        guard isPocketSectionEnabled else {
            self.pocketStories = []
            return succeed()
        }

        return pocketAPI.globalFeed(items: 10).bindQueue(.main) { pStory in
            self.pocketStories = pStory
            return succeed()
        }
    }

    @objc func showMorePocketStories() {
        showSiteWithURLHandler(Pocket.MoreStoriesURL)
    }

    // Invoked by the ActivityStreamDataObserver when highlights/top sites invalidation is complete.
    func didInvalidateDataSources(refresh forced: Bool, topSitesRefreshed: Bool) {
        // Do not reload panel unless we're currently showing the highlight intro or if we
        // force-reloaded the highlights or top sites. This should prevent reloading the
        // panel after we've invalidated in the background on the first load.
        if forced {
            reloadAll()
        }
    }

    func hideURLFromTopSites(_ site: Site) {
        guard let host = site.tileURL.normalizedHost else { return }

        let url = site.tileURL.absoluteString
        // if the default top sites contains the siteurl. also wipe it from default suggested sites.
        if !defaultTopSites().filter({ $0.url == url }).isEmpty {
            deleteTileForSuggestedSite(url)
        }
        profile.history.removeHostFromTopSites(host).uponQueue(.main) { result in
            guard result.isSuccess else { return }
            self.profile.panelDataObservers.activityStream.refreshIfNeeded(forceTopSites: true)
        }
    }

    func pinTopSite(_ site: Site) {
        profile.history.addPinnedTopSite(site).uponQueue(.main) { result in
            guard result.isSuccess else { return }
            self.profile.panelDataObservers.activityStream.refreshIfNeeded(forceTopSites: true)
        }
    }

    func removePinTopSite(_ site: Site) {
        // Special Case: Hide google top site
        if site.guid == GoogleTopSiteConstants.googleGUID {
            let gTopSite = GoogleTopSiteHelper(prefs: self.profile.prefs)
            gTopSite.isHidden = true
        }

        profile.history.removeFromPinnedTopSites(site).uponQueue(.main) { result in
            guard result.isSuccess else { return }
            self.profile.panelDataObservers.activityStream.refreshIfNeeded(forceTopSites: true)
        }
    }

    fileprivate func deleteTileForSuggestedSite(_ siteURL: String) {
        var deletedSuggestedSites = profile.prefs.arrayForKey(TopSitesHandler.DefaultSuggestedSitesKey) as? [String] ?? []
        deletedSuggestedSites.append(siteURL)
        profile.prefs.setObject(deletedSuggestedSites, forKey: TopSitesHandler.DefaultSuggestedSitesKey)
    }

    func defaultTopSites() -> [Site] {
        let suggested = SuggestedSites.asArray()
        let deleted = profile.prefs.arrayForKey(TopSitesHandler.DefaultSuggestedSitesKey) as? [String] ?? []
        return suggested.filter({ deleted.firstIndex(of: $0.url) == .none })
    }

    @objc fileprivate func longPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        guard longPressGestureRecognizer.state == .began else { return }

        let point = longPressGestureRecognizer.location(in: self.collectionView)
        guard let indexPath = self.collectionView?.indexPathForItem(at: point) else { return }

        switch Section(indexPath.section) {
        case .pocket:
            presentContextMenu(for: indexPath)
        case .topSites:
            let topSiteCell = self.collectionView?.cellForItem(at: indexPath) as! ASHorizontalScrollCell
            let pointInTopSite = longPressGestureRecognizer.location(in: topSiteCell.collectionView)
            guard let topSiteIndexPath = topSiteCell.collectionView.indexPathForItem(at: pointInTopSite) else { return }
            presentContextMenu(for: IndexPath(row: topSiteIndexPath.row, section: indexPath.section))
        case .libraryShortcuts, .jumpBackIn, .recentlySaved, .customizeHome, .karmaMenu:
            return
        case .learnAndAct:
            presentContextMenu(for: indexPath)
        }
    }

    fileprivate func fetchBookmarkStatus(for site: Site, completionHandler: @escaping () -> Void) {
        profile.places.isBookmarked(url: site.url).uponQueue(.main) { result in
            let isBookmarked = result.successValue ?? false
            site.setBookmarked(isBookmarked)
            completionHandler()
        }
    }

    func selectItemAtIndex(_ index: Int, inSection section: Section) {
        var site: Site? = nil
        switch section {
        case .pocket:
            site = Site(url: pocketStories[index].url.absoluteString, title: pocketStories[index].title)
            let key = TelemetryWrapper.EventExtraKey.pocketTilePosition.rawValue
            TelemetryWrapper.recordEvent(category: .action, method: .tap, object: .pocketStory, value: nil, extras: [key : "\(index)"])
        case .learnAndAct:
            if let bloc = learnAndAct?.blocs {
                site = Site(url: bloc[index].link, title: bloc[index].title)
            }
        case .topSites, .libraryShortcuts, .jumpBackIn, .recentlySaved, .customizeHome, .karmaMenu:
            return
        }

        if let site = site {
            showSiteWithURLHandler(URIFixup.getURL(site.url)!)
        }
    }
}

// MARK: - Actions Handling

extension KarmaHomeViewController {
    @objc func openTabTray(_ sender: UIButton) {
        if sender.accessibilityIdentifier == FxHomeAccessibilityIdentifiers.MoreButtons.jumpBackIn {
            TelemetryWrapper.recordEvent(category: .action,
                                         method: .tap,
                                         object: .firefoxHomepage,
                                         value: .jumpBackInSectionShowAll)
        }
        homePanelDelegate?.homePanelDidRequestToOpenTabTray(withFocusedTab: nil)
    }

    @objc func openBookmarks(_ sender: UIButton) {
        homePanelDelegate?.homePanelDidRequestToOpenLibrary(panel: .bookmarks)

        if sender.accessibilityIdentifier == FxHomeAccessibilityIdentifiers.MoreButtons.recentlySaved {
            TelemetryWrapper.recordEvent(category: .action,
                                              method: .tap,
                                              object: .firefoxHomepage,
                                              value: .recentlySavedSectionShowAll)
        } else {
            TelemetryWrapper.recordEvent(category: .action,
                                         method: .tap,
                                         object: .firefoxHomepage,
                                         value: .yourLibrarySection,
                                         extras: [TelemetryWrapper.EventObject.libraryPanel.rawValue: TelemetryWrapper.EventValue.bookmarksPanel.rawValue])
        }
    }

    @objc func openHistory() {
        homePanelDelegate?.homePanelDidRequestToOpenLibrary(panel: .history)
        TelemetryWrapper.recordEvent(category: .action,
                                     method: .tap,
                                     object: .firefoxHomepage,
                                     value: .yourLibrarySection,
                                     extras: [TelemetryWrapper.EventObject.libraryPanel.rawValue: TelemetryWrapper.EventValue.historyPanel.rawValue])
    }

    @objc func openReadingList() {
        homePanelDelegate?.homePanelDidRequestToOpenLibrary(panel: .readingList)
        TelemetryWrapper.recordEvent(category: .action,
                                     method: .tap,
                                     object: .firefoxHomepage,
                                     value: .yourLibrarySection,
                                     extras: [TelemetryWrapper.EventObject.libraryPanel.rawValue: TelemetryWrapper.EventValue.readingListPanel.rawValue])
    }

    @objc func openDownloads() {
        homePanelDelegate?.homePanelDidRequestToOpenLibrary(panel: .downloads)
        TelemetryWrapper.recordEvent(category: .action,
                                     method: .tap,
                                     object: .firefoxHomepage,
                                     value: .yourLibrarySection,
                                     extras: [TelemetryWrapper.EventObject.libraryPanel.rawValue: TelemetryWrapper.EventValue.downloadsPanel.rawValue])
    }

    @objc func openCustomizeHomeSettings() {
        homePanelDelegate?.homePanelDidRequestToCustomizeHomeSettings()
        TelemetryWrapper.recordEvent(category: .action,
                                     method: .tap,
                                     object: .firefoxHomepage,
                                     value: .customizeHomepageButton)
    }
}

// MARK: - Context Menu

extension KarmaHomeViewController: HomePanelContextMenu {
    func presentContextMenu(for site: Site, with indexPath: IndexPath, completionHandler: @escaping () -> PhotonActionSheet?) {

        fetchBookmarkStatus(for: site) {
            guard let contextMenu = completionHandler() else { return }
            self.present(contextMenu, animated: true, completion: nil)
        }
    }

    func getSiteDetails(for indexPath: IndexPath) -> Site? {
        switch Section(indexPath.section) {
        case .pocket:
            return Site(url: pocketStories[indexPath.row].url.absoluteString, title: pocketStories[indexPath.row].title)
        case .learnAndAct:
            if let blocs = learnAndAct?.blocs {
                return Site(url: blocs[indexPath.row].link, title: blocs[indexPath.row].title)
            }
            return nil
        case .topSites:
            return topSitesManager.content[indexPath.item]
        case .libraryShortcuts, .jumpBackIn, .recentlySaved, .customizeHome, .karmaMenu:
            return nil
        }
    }

    func getContextMenuActions(for site: Site, with indexPath: IndexPath) -> [PhotonActionSheetItem]? {
        guard let siteURL = URL(string: site.url) else { return nil }
        var sourceView: UIView?

        switch Section(indexPath.section) {
        case .topSites:
            if let topSiteCell = self.collectionView?.cellForItem(at: IndexPath(row: 0, section: 0)) as? ASHorizontalScrollCell {
                sourceView = topSiteCell.collectionView.cellForItem(at: indexPath)
            }
        case .learnAndAct:
            sourceView = self.collectionView?.cellForItem(at: indexPath)
        case .pocket:
            sourceView = self.collectionView?.cellForItem(at: indexPath)
        case .libraryShortcuts, .jumpBackIn, .recentlySaved, .customizeHome, .karmaMenu:
            return nil
        }

        let openInNewTabAction = PhotonActionSheetItem(title: .OpenInNewTabContextMenuTitle, iconString: "quick_action_new_tab") { _, _ in
            self.homePanelDelegate?.homePanelDidRequestToOpenInNewTab(siteURL, isPrivate: false)
            if Section(indexPath.section) == .pocket {
                TelemetryWrapper.recordEvent(category: .action, method: .tap, object: .pocketStory)
            }
        }

        let openInNewPrivateTabAction = PhotonActionSheetItem(title: .OpenInNewPrivateTabContextMenuTitle, iconString: "quick_action_new_private_tab") { _, _ in
            self.homePanelDelegate?.homePanelDidRequestToOpenInNewTab(siteURL, isPrivate: true)
        }

        let bookmarkAction: PhotonActionSheetItem
        if site.bookmarked ?? false {
            bookmarkAction = PhotonActionSheetItem(title: .RemoveBookmarkContextMenuTitle, iconString: "action_bookmark_remove", handler: { _, _ in
                self.profile.places.deleteBookmarksWithURL(url: site.url) >>== {
                    self.profile.panelDataObservers.activityStream.refreshIfNeeded(forceTopSites: false)
                    site.setBookmarked(false)
                }

                TelemetryWrapper.recordEvent(category: .action, method: .delete, object: .bookmark, value: .activityStream)
            })
        } else {
            bookmarkAction = PhotonActionSheetItem(title: .BookmarkContextMenuTitle, iconString: "action_bookmark", handler: { _, _ in
                let shareItem = ShareItem(url: site.url, title: site.title, favicon: site.icon)
                _ = self.profile.places.createBookmark(parentGUID: BookmarkRoots.MobileFolderGUID, url: shareItem.url, title: shareItem.title)

                var userData = [QuickActions.TabURLKey: shareItem.url]
                if let title = shareItem.title {
                    userData[QuickActions.TabTitleKey] = title
                }
                QuickActions.sharedInstance.addDynamicApplicationShortcutItemOfType(.openLastBookmark,
                                                                                    withUserData: userData,
                                                                                    toApplication: .shared)
                site.setBookmarked(true)
                self.profile.panelDataObservers.activityStream.refreshIfNeeded(forceTopSites: true)
                TelemetryWrapper.recordEvent(category: .action, method: .add, object: .bookmark, value: .activityStream)
            })
        }

        let shareAction = PhotonActionSheetItem(title: .ShareContextMenuTitle, iconString: "action_share", handler: { _, _ in
            let helper = ShareExtensionHelper(url: siteURL, tab: nil)
            let controller = helper.createActivityViewController { (_, _) in }
            if UIDevice.current.userInterfaceIdiom == .pad, let popoverController = controller.popoverPresentationController {
                let cellRect = sourceView?.frame ?? .zero
                let cellFrameInSuperview = self.collectionView?.convert(cellRect, to: self.collectionView) ?? .zero

                popoverController.sourceView = sourceView
                popoverController.sourceRect = CGRect(origin: CGPoint(x: cellFrameInSuperview.size.width/2, y: cellFrameInSuperview.height/2), size: .zero)
                popoverController.permittedArrowDirections = [.up, .down, .left]
                popoverController.delegate = self
            }
            self.present(controller, animated: true, completion: nil)
        })

        let removeTopSiteAction = PhotonActionSheetItem(title: .RemoveContextMenuTitle, iconString: "action_remove", handler: { _, _ in
            self.hideURLFromTopSites(site)
        })

        let pinTopSite = PhotonActionSheetItem(title: .AddToShortcutsActionTitle, iconString: "action_pin", handler: { _, _ in
            self.pinTopSite(site)
        })

        let removePinTopSite = PhotonActionSheetItem(title: .RemoveFromShortcutsActionTitle, iconString: "action_unpin", handler: { _, _ in
            self.removePinTopSite(site)
        })

        let topSiteActions: [PhotonActionSheetItem]
        if let _ = site as? PinnedSite {
            topSiteActions = [removePinTopSite]
        } else {
            topSiteActions = [pinTopSite, removeTopSiteAction]
        }

        var actions = [openInNewTabAction, openInNewPrivateTabAction, bookmarkAction, shareAction]

        switch Section(indexPath.section) {
        case .pocket, .libraryShortcuts, .jumpBackIn, .recentlySaved, .customizeHome, .karmaMenu, .learnAndAct: break
        case .topSites: actions.append(contentsOf: topSiteActions)
        }

        return actions
    }
}

// MARK: - Popover Presentation Delegate

extension KarmaHomeViewController: UIPopoverPresentationControllerDelegate {

    // Dismiss the popover if the device is being rotated.
    // This is used by the Share UIActivityViewController action sheet on iPad
    func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in view: AutoreleasingUnsafeMutablePointer<UIView>) {
        guard hasPresentedContextualHint else {
            popoverPresentationController.presentedViewController.dismiss(animated: false, completion: nil)
            return
        }
        rect.pointee = contextualSourceView.bounds
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        contextualHintViewController.removeFromParent()
        hasPresentedContextualHint = false
        overlayView.isHidden = true
        return true
    }
}
