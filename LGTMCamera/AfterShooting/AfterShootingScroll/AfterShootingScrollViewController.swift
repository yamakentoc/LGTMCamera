//
//  AfterShootingScrollViewController.swift
//  LGTMCamera
//
//  Created by 山口賢登 on 2019/01/11.
//  Copyright © 2019 山口賢登. All rights reserved.
//

import UIKit

class AfterShootingScrollViewController: UIViewController {

    var presenter: AfterShootingScrollViewPresenter!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = AfterShootingScrollViewPresenter(view: self)
    }
}

extension AfterShootingScrollViewController: AfterShootingScrollViewPresenterProtocol {
    
}
