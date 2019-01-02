//
//  ShootingViewPresenter.swift
//  LGTMCamera
//
//  Created by 山口賢登 on 2018/12/28.
//  Copyright © 2018 山口賢登. All rights reserved.
//

import UIKit

protocol ShootingViewPresenterProtocol: class {
    
}

class ShootingViewPresenter: NSObject {
    
    private let view: ShootingViewPresenterProtocol
    
    init(view: ShootingViewPresenterProtocol) {
        self.view = view
    }
    
}
