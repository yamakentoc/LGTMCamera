//
//  AfterShootingScrollViewPresenter.swift
//  LGTMCamera
//
//  Created by 山口賢登 on 2019/01/11.
//  Copyright © 2019 山口賢登. All rights reserved.
//

import Foundation

protocol AfterShootingScrollViewPresenterProtocol: class {
    
}

class AfterShootingScrollViewPresenter: NSObject {
    private let view: AfterShootingScrollViewPresenterProtocol
    
    init(view: AfterShootingScrollViewPresenterProtocol) {
        self.view = view
    }
    
}
