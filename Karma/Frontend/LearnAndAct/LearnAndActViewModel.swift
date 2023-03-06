//
//  LearnAndActiViewModel.swift
//  Client
//
//  Created by Lilla on 16/11/2021.
//  Copyright © 2021 Mozilla. All rights reserved.
//

import Foundation
import SwiftyJSON
import Storage
import Shared

// MARK: - Bloc

class LearnAndActCellViewModel {
        
    var type: LearnAndActContentType { item.contentType }
    var typeString: String { item.contentString }
    var duration: String = ""
    var mobileImage: String { item.imageURL }
    var title: String { item.title }
    var description: String { item.description }
    var action: String { item.action }
    var link: String { item.link }
    
    var tag: Int = 0
    /*var defaultImageName: String {
        if type == .learn {
            return "learn-crash-test"
        } else if type == .
        return "act-crash-test"
    }*/
    
    private let item: LearnAndActBloc

    init(item: LearnAndActBloc) {
        self.item = item
    }
    
    var onTap: (IndexPath) -> Void = { _ in }
    
    var typeIsHidden: Bool {
        switch self.type {
        case .news:
            return false
        case .victory:
            return false
        case .act:
            return false
        case .learn:
            return false
        case .undefined:
            return true
        }
    }
    
    var typeBackgroundColor: UIColor {
        switch self.type {
        case .news:
            return UIColor(colorString: "E5D9FD")
        case .victory:
            return UIColor(colorString: "FEF2D6")
        case .act:
            return UIColor(colorString: "FFDDCC")
        case .learn:
            return UIColor(colorString: "D4FCD4")
        case .undefined:
            return UIColor(colorString: "FFDDCC")
        }
    }
    
    var typeLabelColor: UIColor {
        switch self.type {
        case .news:
            return UIColor(colorString: "6640DA")
        case .victory:
            return UIColor(colorString: "B5551A")
        case .act:
            return UIColor(colorString: "DB0012")
        case .learn:
            return UIColor(colorString: "0D7657")
        case .undefined:
            return UIColor(colorString: "FFDDCC")
        }
    }
    
    var typeImageName: String {
        switch self.type {
        case .news:
            return "learn_and_act_news"
        case .victory:
            return "learn_and_act_victory"
        case .act:
            return "learn_and_act_act"
        case .learn:
            return "learn_and_act_learn"
        case .undefined:
            return ""
        }
    }
    
}


class LearnAndActViewModel {
    struct UX {
        static let numberOfItemsInColumn = 1
        static let fractionalWidthiPhonePortrait: CGFloat = 1
        static let fractionalWidthiPhoneLanscape: CGFloat = 0.46
    }
    
    private var learnAndActViewModels: [LearnAndActCellViewModel] = [LearnAndActCellViewModel]()
    var onLongPressTileAction: ((Site, UIView?) -> Void)?
    var onTapTileAction: ((URL) -> Void)?
    weak var delegate: HomepageDataModelDelegate?
    private var dataAdaptor: LearnAndActDataAdaptor
    private var isLoading: Bool = true
    var theme: Theme
    var prepareContextualHint: ((LearnAndActViewCell) -> Void)?

    init(dataAdaptor: LearnAndActDataAdaptor,
         theme: Theme){
        self.dataAdaptor = dataAdaptor
        self.theme = theme
    }
    
    private func bind(viewModel: LearnAndActCellViewModel) {
        viewModel.onTap = { [weak self] indexPath in
            
            if let siteUrl = self?.learnAndActViewModels[indexPath.row].link,
                let url = URL(string: siteUrl) {
                self?.onTapTileAction?(url)
            }
        }

        learnAndActViewModels.append(viewModel)
    }

    private func updateData() {
        guard let articles = dataAdaptor.getLearnAndActData() else { return }
        learnAndActViewModels = []
        for article in articles.blocs {
            bind(viewModel: .init(item: article))
        }
        

    }
    
    func loadNewPage() {
        if !isLoading {
            isLoading = true
            dataAdaptor.loadNewPage()
        }
    }
    
    func getWidthDimension(device: UIUserInterfaceIdiom = UIDevice.current.userInterfaceIdiom,
                           isLandscape: Bool = UIWindow.isLandscape) -> NSCollectionLayoutDimension {
         if device == .pad {
            return .absolute(LearnAndActViewCell.UX.cellWidth) 
        }  else {
            return .absolute(UIScreen.main.bounds.size.width - LearnAndActViewCell.UX.padding*2)
        }
    }
    
    func getHeightDimension(device: UIUserInterfaceIdiom = UIDevice.current.userInterfaceIdiom,
                           isLandscape: Bool = UIWindow.isLandscape) -> NSCollectionLayoutDimension {
         if device == .pad  || isLandscape{
            return .absolute(LearnAndActViewCell.UX.cellHeightLandscape)
         }
        else {
            return .estimated(LearnAndActViewCell.UX.cellHeight)
        }
    }
}

extension LearnAndActViewModel: HomepageSectionHandler {
    
    func configure(_ collectionView: UICollectionView,
                   at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LearnAndActViewCell.cellIdentifier,
                                                      for: indexPath) as! LearnAndActViewCell
        let viewModel = learnAndActViewModels[indexPath.row]
        viewModel.tag = indexPath.row
        cell.learnAndAct = viewModel
        prepareContextualHint?(cell)
        return cell
    }

    func configure(_ cell: UICollectionViewCell,
                   at indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }

    func didSelectItem(at indexPath: IndexPath,
                       homePanelDelegate: HomePanelDelegate?,
                       libraryPanelDelegate: LibraryPanelDelegate?) {
        learnAndActViewModels[indexPath.row].onTap(indexPath)
    }

    func handleLongPress(with collectionView: UICollectionView, indexPath: IndexPath) {
        guard let onLongPressTileAction = onLongPressTileAction else { return }


        let site = Site(url: learnAndActViewModels[indexPath.row].link, title: learnAndActViewModels[indexPath.row].title)

        let sourceView = collectionView.cellForItem(at: indexPath)
        onLongPressTileAction(site, sourceView)
    }
    
}

extension LearnAndActViewModel: HomepageViewModelProtocol, FeatureFlaggable {

    func setTheme(theme: Shared.Theme) {
        self.theme = theme
    }
    
    var sectionType: HomepageSectionType {
        .learnAndAct
    }
        
    func section(for traitCollection: UITraitCollection, size: CGSize) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: getHeightDimension()
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: getWidthDimension(),
            heightDimension: .estimated(LearnAndActViewCell.UX.cellHeight)
        )

        let subItems = Array(repeating: item, count: self.learnAndActViewModels.count)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: subItems)
        group.interItemSpacing = LearnAndActViewCell.UX.interItemSpacing
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: LearnAndActViewCell.UX.interGroupSpacing)

        let section = NSCollectionLayoutSection(group: group)
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                heightDimension: .estimated(34))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: UICollectionView.elementKindSectionHeader,
                                                                 alignment: .top)
        section.boundarySupplementaryItems = [header]
        section.visibleItemsInvalidationHandler = { (visibleItems, point, env) -> Void in
            //self.onScroll?(visibleItems)
        }

        let leadingInset = HomepageViewModel.UX.leadingInset(traitCollection: traitCollection)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                        leading: leadingInset,
                                                        bottom: HomepageViewModel.UX.spacingBetweenSections,
                                                        trailing: 0)
        section.orthogonalScrollingBehavior = .continuous
        return section
    }
    
    func numberOfItemsInSection() -> Int {
        return self.learnAndActViewModels.count
    }
    
    var headerViewModel: LabelButtonHeaderViewModel {
        
        return LabelButtonHeaderViewModel.emptyHeader
    }
    
    var isEnabled: Bool {
        return featureFlags.isFeatureEnabled(.learnAndAct, checking: .buildAndUser)
    }
    
    var shouldShow: Bool {
        return !self.learnAndActViewModels.isEmpty
    }
    
    var hasData: Bool {
        return !self.learnAndActViewModels.isEmpty
    }
    
}

extension LearnAndActViewModel: LearnAndActDelegate {
    func didLoadNewData() {
        isLoading = false
        ensureMainThread {
            self.updateData()
            guard self.isEnabled else { return }
            self.delegate?.reloadView()
        }
    }
}
