//
//  AfterShootingScrollViewPresenter.swift
//  LGTMCamera
//
//  Created by 山口賢登 on 2019/01/11.
//  Copyright © 2019 山口賢登. All rights reserved.
//

import Foundation

protocol BottomMenuViewPresenterProtocol: class {
    
}

class BottomMenuViewPresenter: NSObject {
    private let view: BottomMenuViewPresenterProtocol
    
    init(view: BottomMenuViewPresenterProtocol) {
        self.view = view
    }
    
}
