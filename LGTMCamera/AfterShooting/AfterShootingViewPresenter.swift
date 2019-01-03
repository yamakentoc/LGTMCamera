//
//  AfterShootingViewPresenter.swift
//  LGTMCamera
//
//  Created by 山口賢登 on 2019/01/02.
//  Copyright © 2019 山口賢登. All rights reserved.
//

import UIKit

protocol AfterShootingViewPresenterProtocol: class {
    
}

class AfterShootingViewPresenter: NSObject {
    private let view: AfterShootingViewPresenterProtocol
    
    init(view: AfterShootingViewPresenterProtocol) {
        self.view = view
    }
    
}
