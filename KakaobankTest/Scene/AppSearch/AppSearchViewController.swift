//
//  AppSearchViewController.swift
//  KakaobankTest
//
//  Created by rowkaxl on 04/05/2019.
//  Copyright (c) 2019 rowkaxl. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import RxGesture
import SnapKit
import RxKeyboard
import Async

protocol AppSearchDisplayLogic: class {
    func displayRecentHistory(viewModel: AppSearch.RecentHitory.ViewModel)
    func displaySearchWordHistory(viewModel: AppSearch.SearchWordHitory.ViewModel)
    func displaySearchAppStore(viewModel: AppSearch.SearchAppStore.ViewModel)
}

class AppSearchViewController: UIViewController, AppSearchDisplayLogic {
    var interactor: AppSearchBusinessLogic?
    var router: (NSObjectProtocol & AppSearchRoutingLogic & AppSearchDataPassing)?
    
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
        let interactor = AppSearchInteractor()
        let presenter = AppSearchPresenter()
        let router = AppSearchRouter()
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
        interactor?.doRecentHistory()
    }
    
    // MARK: Do something
    
    private let disposeBag = DisposeBag()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var recentTv: UITableView!
    @IBOutlet weak var searchBaseView: UIView!
    @IBOutlet weak var searchTv: UITableView!
    @IBOutlet weak var searchBaseViewBottom: NSLayoutConstraint!
    
    public let recentSectionModels = BehaviorRelay<[AppSearchBaseItemSection]>(value: [])
    public let searchSectionModels = BehaviorRelay<[AppSearchBaseItemSection]>(value: [])
    
    func displayRecentHistory(viewModel: AppSearch.RecentHitory.ViewModel) {
        recentSectionModels.accept(viewModel.sectionModels)
    }
    
    func displaySearchWordHistory(viewModel: AppSearch.SearchWordHitory.ViewModel) {
        searchSectionModels.accept(viewModel.sectionModels)
    }
    
    func displaySearchAppStore(viewModel: AppSearch.SearchAppStore.ViewModel) {
        searchSectionModels.accept(viewModel.sectionModels)
    }
}

extension AppSearchViewController: UITableViewDelegate {
    
    private func configure() {
        configureUI()
        configureRx()
    }
    
    private func configureUI() {
        self.navigationController?.navigationBar.shadowImage = UIColor.white.as1ptImage()
        
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        //
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "App Store"
        searchController.searchBar.setValue("취소", forKey: "_cancelButtonText")
        
        navigationItem.searchController = searchController
        //
        navigationItem.hidesSearchBarWhenScrolling = false
        
        //
        definesPresentationContext = true
        
//        self.navigationController?.navigationBar.hideBottomLine()
    }
    
    private func configureRx() {
        
        let recentDs = RxTableViewSectionedReloadDataSource<AppSearchBaseItemSection>(configureCell: {(_, tv, indexPath, item) -> UITableViewCell in
            
            let cell = tv.dequeueReusableCell(withIdentifier: "AppSearchHistoryListCell", for: indexPath) as! AppSearchHistoryListCell
            if let model = item.object as? RecentHistoryModel, let status = self.router?.dataStore?.appSearchStatus {
                cell.configure(model: model, type: item.type, status: status)
            }
            
            return cell
        })
        
        let searchDs = RxTableViewSectionedReloadDataSource<AppSearchBaseItemSection>(configureCell: {(_, tv, indexPath, item) -> UITableViewCell in
            
            
            switch item.type {
            case .searchWordList:
                let cell = tv.dequeueReusableCell(withIdentifier: "AppRecentHistoryListCell", for: indexPath) as! AppRecentHistoryListCell
                if let model = item.object as? SearchHistoryModel {
                    cell.configure(model: model)
                }
                
                return cell
            case .searchAppInfoList:
                let cell = tv.dequeueReusableCell(withIdentifier: "AppItemCell", for: indexPath) as! AppItemCell
                if let model = item.object as? AppInfoModel {
                    cell.configure(model: model)
                }
                
                
                return cell
            default: return UITableViewCell()
            }
        })
        
        recentSectionModels.bind(to: recentTv.rx.items(dataSource: recentDs)).disposed(by: self.disposeBag)
        searchSectionModels.bind(to: searchTv.rx.items(dataSource: searchDs)).disposed(by: self.disposeBag)
        
        // 최근검색어 선택
        recentTv.rx.itemSelected
            .subscribe(onNext: { (indexPath) in
                
                self.recentTv.reloadRows(at: [indexPath], with: .none)
                guard indexPath.section > 0 else { return }
                guard let searchWord = self.router?.dataStore?.recentHistoryModels?[indexPath.section-1].searchWord else { return }
                
                self.searchController.searchBar.text = searchWord
                self.searchController.isActive = true
                self.setAppSearchStatus(status: .searchComplete)
                
                Async.background(after: 0.2) {
                    let request = AppSearch.SearchAppStore.Request(query: searchWord)
                    self.interactor?.doSearchAppStore(request: request)
                }
            })
            .disposed(by: disposeBag)
        
        // 검색한 앱선택
        searchTv.rx.itemSelected
            .subscribe(onNext: { (indexPath) in
                
                guard var data = self.router?.dataStore else { return }
                
                if data.appSearchStatus == .searching {
                    
                    self.recentTv.reloadRows(at: [indexPath], with: .none)
                    guard let query = data.searchHistoryModels?[indexPath.section].searchWord else { return }
                    
                    self.searchController.searchBar.text = query
                    self.searchController.searchBar.endEditing(true)
                    self.setAppSearchStatus(status: .searchComplete)
                    
                    let request = AppSearch.SearchAppStore.Request(query: query)
                    self.interactor?.doSearchAppStore(request: request)
                    
                } else if data.appSearchStatus == .searchComplete {
                    
                    guard let model = data.appInfoModels?[indexPath.section] else { return }
                    print(model.trackName)
                }
                
                
            })
            .disposed(by: disposeBag)
        
        // 검색하단뷰 터치(검색어 없을 경우)
        searchBaseView.rx.tapGesture()
            .filter({_ in
                guard var data = self.router?.dataStore else { return false }
                return data.appSearchStatus == .searchStart
            })
            .subscribe(onNext: { [weak self](_) in
                guard let self = self else { return }
                self.searchController.isActive = false
            }).disposed(by: disposeBag)
        
        // 검색완료 클릭
        searchController.searchBar.rx
            .searchButtonClicked
            .subscribe(onNext: { (_) in
                guard let query = self.searchController.searchBar.text else { return }
                let request = AppSearch.SearchAppStore.Request(query: query)
                self.interactor?.doSearchAppStore(request: request)

                self.setAppSearchStatus(status: .searchComplete)
            })
            .disposed(by: disposeBag)
        
        // 검색바 취소 클릭시
        searchController.searchBar.rx
            .cancelButtonClicked
            .subscribe(onNext: { (_) in
                // 앱검색 정보 클리어
                self.searchSectionModels.accept([])
            })
            .disposed(by: disposeBag)
        
        // 키보드 동작
        RxKeyboard.instance.visibleHeight
            .skip(1)
            .drive(onNext: { [weak self] (height) in
                guard let self = self else { return }
                self.searchBaseViewBottom.constant = height
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                })
            })
            .disposed(by: disposeBag)
        
    }
}

extension AppSearchViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return text.checkKorean || text.isEmpty
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text, !text.isEmpty else { return }
        
        setAppSearchStatus(status: .searching)
        
        let request = AppSearch.SearchWordHitory.Request(query: text)
        self.interactor?.doSearchWordHistory(request: request)
    }
}

extension AppSearchViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {

        guard var data = self.router?.dataStore, data.appSearchStatus != .searchBefore else { return }

        if searchController.searchBar.text!.isEmpty {
            setAppSearchStatus(status: .searchStart)
        } else {
            setAppSearchStatus(status: .searching)
        }
    }
}

extension AppSearchViewController: UISearchControllerDelegate {
 
    func willPresentSearchController(_ searchController: UISearchController) {
        print("willPresentSearchController")
        showSearchBaseView()
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        print("willDismissSearchController")
        hideSearchBaseView()
    }
}

extension AppSearchViewController {
    
    func showSearchBaseView() {
        setAppSearchStatus(status: .searchStart)
        recentTv.reloadData()
    }
    
    func hideSearchBaseView() {
        setAppSearchStatus(status: .searchBefore)
        recentTv.reloadData()
    }
    
    func setAppSearchStatus(status: AppSearchStatus) {
        guard var data = router?.dataStore  else { return }
        data.appSearchStatus = status
        setSerchViewStatus(status: data.appSearchStatus)
    }
    
    func setSerchViewStatus(status: AppSearchStatus) {
        self.searchTv.alpha = status.tableViewAlpha
        self.searchBaseView.backgroundColor = status.baseViewBackgroundColor
        self.searchBaseView.alpha = status.baseViewAlpha
    }
}


//UIView.animate(withDuration: 0.3,
//               animations: { () -> Void in
//
//                self.searchTv.alpha = 0.5
//
//}, completion: { (_) -> Void in
//
//})
