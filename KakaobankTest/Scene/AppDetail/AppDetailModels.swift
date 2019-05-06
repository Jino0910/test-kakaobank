//
//  AppDetailModels.swift
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

enum AppDetail {
    // MARK: Use cases
    
    enum AppDetailInfo {
        struct Request {
            
        }
        struct Response {
            var appInfoModel: AppInfoModel
        }
        struct ViewModel {
            var sectionModels: [AppSearchBaseItemSection]
        }
    }
}

