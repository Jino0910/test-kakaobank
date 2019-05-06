//
//  AppDetailViewController.swift
//  KakaobankTest
//
//  Created by rowkaxl on 06/05/2019.
//  Copyright (c) 2019 rowkaxl. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SwiftyJSON
import SafariServices

protocol AppDetailDisplayLogic: class {
    func displaySectionModels(viewModel: AppDetail.AppDetailInfo.ViewModel)
}

class AppDetailViewController: UIViewController, AppDetailDisplayLogic {
    var interactor: AppDetailBusinessLogic?
    var router: (NSObjectProtocol & AppDetailRoutingLogic & AppDetailDataPassing)?
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = AppDetailInteractor()
        let presenter = AppDetailPresenter()
        let router = AppDetailRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        interactor?.doSectionModels()
    }
    
    // MARK: Do something
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var cv: UICollectionView! {
        didSet {
            let flowLayout: UICollectionViewFlowLayout! = UICollectionViewFlowLayout()
            flowLayout.sectionHeadersPinToVisibleBounds = true
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 0
            
            cv.collectionViewLayout = flowLayout
            cv.showsVerticalScrollIndicator = false
            cv.showsHorizontalScrollIndicator = false
        }
    }
    
    var dataSource: RxCollectionViewSectionedReloadDataSource<AppSearchBaseItemSection>?
 
    public let sectionModels = BehaviorRelay<[AppSearchBaseItemSection]>(value: [])
    
    var screenShotHeight: CGFloat = 450
    
    func displaySectionModels(viewModel: AppDetail.AppDetailInfo.ViewModel) {
        sectionModels.accept(viewModel.sectionModels)
    }
}

extension AppDetailViewController: UITableViewDelegate {
    
    private func configure() {
        configureUI()
        configureRx()
    }
    
    private func configureUI() {
        cv.rx.setDelegate(self).disposed(by: self.disposeBag)
        
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    
    private func configureRx() {
        
        dataSource = RxCollectionViewSectionedReloadDataSource<AppSearchBaseItemSection>(
            configureCell: { (_, cv, indexPath, item) -> UICollectionViewCell in
                
                guard let model = self.router?.dataStore?.appInfoModel else { return UICollectionViewCell() }
                
                switch item.type {
                case .detailHeader:
                    let cell = cv.dequeueReusableCell(withReuseIdentifier: "AppDetailHeaderCell", for: indexPath) as! AppDetailHeaderCell
                    cell.configure(model: model)
                    return cell
                case .detailSubHeader:
                    let cell = cv.dequeueReusableCell(withReuseIdentifier: "AppDetailSubHeaderCell", for: indexPath) as! AppDetailSubHeaderCell
                    cell.configure(model: model)
                    return cell
                case .detailScreenShot:
                    let cell = cv.dequeueReusableCell(withReuseIdentifier: "AppDetailScreenShotCell", for: indexPath) as! AppDetailScreenShotCell
                    cell.configure(model: model)
                    cell.handler = { [weak self] height in
                        self?.screenShotHeight = height
                        cv.performBatchUpdates({})
                    }
                    return cell
                case .detailDescription:
                    let cell = cv.dequeueReusableCell(withReuseIdentifier: "AppDetailDescriptionCell", for: indexPath) as! AppDetailDescriptionCell
                    cell.configure(model: model)
                    cell.handler = { cv.performBatchUpdates({}) }
                    return cell
                case .detailDeveloperInfo:
                    let cell = cv.dequeueReusableCell(withReuseIdentifier: "AppDetailDeveloperInfoCell", for: indexPath) as! AppDetailDeveloperInfoCell
                    cell.configure(model: model)
                    return cell
//                case .detailRating:
//                case .detailReviews:
//                case .detailNewFeature:
//                case .detailInfomation:
                    
                default: return UICollectionViewCell()
                }
        })
        
        if let dataSource = dataSource {
            sectionModels.bind(to: cv.rx.items(dataSource: dataSource)).disposed(by: self.disposeBag)
        }
    
        // 최근검색어 선택
        cv.rx.itemSelected
            .subscribe(onNext: { (indexPath) in
                
                if (self.cv.cellForItem(at: indexPath) as? AppDetailDeveloperInfoCell) != nil {
                    
                    guard let model = self.router?.dataStore?.appInfoModel else { return }
                    guard let url = URL(string: model.artistViewUrl) else { return }
                    let vc = SFSafariViewController(url: url)
                    self.present(vc, animated: true, completion: {})
                }
            })
            .disposed(by: disposeBag)
        
    }
}

extension AppDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let dataSource = dataSource else { return .zero }
        
        let section = dataSource[indexPath.section]
        let item = section.items[indexPath.item]
        
        let width = UIScreen.main.bounds.width
        
        print(item.type)
        
        switch item.type {
            
        case .detailHeader: return CGSize(width: width, height: AppDetailHeaderCell.cellHeight)
        case .detailSubHeader: return CGSize(width: width, height: AppDetailSubHeaderCell.cellHeight)
        case .detailScreenShot: return CGSize(width: width, height: AppDetailScreenShotCell.bottomMargin+screenShotHeight)
        case .detailDescription:
            guard let model = self.router?.dataStore?.appInfoModel else { return .zero }
            if let cell = cv.cellForItem(at: indexPath) as? AppDetailDescriptionCell {
                return CGSize(width: width, height: cell.cellHeight(width: width, desc: model.description))
            } else {
                return CGSize(width: width, height: AppDetailDescriptionCell.cellHeight())
            }
        case .detailDeveloperInfo: return CGSize(width: width, height: AppDetailDeveloperInfoCell.cellHeight)
            
            
//        case .detailRating:
//        case .detailReviews:
//        case .detailNewFeature:
//        case .detailInfomation:
  
        default: return .zero
        }
    }
}

