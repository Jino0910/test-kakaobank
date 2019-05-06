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
    
    func displaySectionModels(viewModel: AppDetail.AppDetailInfo.ViewModel) {
        sectionModels.accept(viewModel.sectionModels)
    }
    
//    var pageSize: CGFloat {
//        return 210
//    }
//
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        targetContentOffset.pointee.x = getTargetContentOffset(scrollView: scrollView, velocity: velocity)
//    }
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
                    
                    
                default: return UICollectionViewCell()
                }
        })
        
        if let dataSource = dataSource {
            sectionModels.bind(to: cv.rx.items(dataSource: dataSource)).disposed(by: self.disposeBag)
        }
        
        
        
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
        
        switch item.type {
            
        case .detailHeader: return CGSize(width: width, height: AppDetailHeaderCell.cellHeight)
        case .detailSubHeader: return CGSize(width: width, height: AppDetailSubHeaderCell.cellHeight)
            
        default: return .zero
        }
    }
}

