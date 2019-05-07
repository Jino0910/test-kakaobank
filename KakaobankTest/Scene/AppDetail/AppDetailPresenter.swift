//
//  AppDetailPresenter.swift
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

protocol AppDetailPresentationLogic {
    func presentSectionModels(response: AppDetail.AppDetailInfo.Response)
}

class AppDetailPresenter: AppDetailPresentationLogic {
    weak var viewController: AppDetailDisplayLogic?
    
    // MARK: Do something
    
    func presentSectionModels(response: AppDetail.AppDetailInfo.Response) {
        
        let sectionModels = self.getAppDetailSectionModel(appInfoModel: response.appInfoModel)
        let viewModel = AppDetail.AppDetailInfo.ViewModel(sectionModels: sectionModels)
        viewController?.displaySectionModels(viewModel: viewModel)
    }
}

extension AppDetailPresenter {

    func getAppDetailSectionModel(appInfoModel: AppInfoModel) -> [AppSearchBaseItemSection] {
        
        let sectionModels: [AppSearchBaseItemSection] = [
            AppSearchBaseItemSection(items: [
                AppSearchBaseItem(type: .detailHeader, object: appInfoModel),
                AppSearchBaseItem(type: .detailSubHeader, object: appInfoModel),
                AppSearchBaseItem(type: .detailScreenShot, object: appInfoModel),
                AppSearchBaseItem(type: .detailDescription, object: appInfoModel),
                AppSearchBaseItem(type: .detailDeveloperInfo, object: appInfoModel),
                AppSearchBaseItem(type: .detailRating, object: appInfoModel),
                AppSearchBaseItem(type: .detailReviews, object: appInfoModel),
                AppSearchBaseItem(type: .detailNewFeatureVersion, object: appInfoModel),
                AppSearchBaseItem(type: .detailNewFeatureDescription, object: appInfoModel),
                AppSearchBaseItem(type: .detailInformationTitle, object: appInfoModel),
                AppSearchBaseItem(type: .detailInformationContent, object: appInfoModel)
                ])
        ]
        return sectionModels
    }
}

