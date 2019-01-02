//
//  HomeViewPresenter.swift
//  LGTMCamera
//
//  Created by 山口賢登 on 2018/12/28.
//  Copyright © 2018 山口賢登. All rights reserved.
//

import UIKit

protocol HomeViewPresenterProtocol: class {
    
}

class HomeViewPresenter: NSObject {
    
    private let view: HomeViewPresenterProtocol
    
    init(view: HomeViewPresenterProtocol) {
        self.view = view
    }
    
}
