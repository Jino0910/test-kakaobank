//
//  AppDetailInteractor.swift
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

protocol AppDetailBusinessLogic {
    func doSectionModels()
}

protocol AppDetailDataStore {
    var appInfoModel: AppInfoModel { get set }
}

class AppDetailInteractor: AppDetailBusinessLogic, AppDetailDataStore {
    var presenter: AppDetailPresentationLogic?
    var worker: AppDetailWorker?
    
    var appInfoModel: AppInfoModel = AppInfoModel()
    
    // MARK: Do something
    
    func doSectionModels() {

        let response = AppDetail.AppDetailInfo.Response(appInfoModel: appInfoModel)
        presenter?.presentSectionModels(response: response)
    }
}


