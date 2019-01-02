//
//  AfterShootingViewController.swift
//  LGTMCamera
//
//  Created by 山口賢登 on 2019/01/02.
//  Copyright © 2019 山口賢登. All rights reserved.
//

import UIKit

class AfterShootingViewController: UIViewController {

    var presenter: AfterShootingViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = AfterShootingViewPresenter(view: self)
    }

}

extension AfterShootingViewController: AfterShootingViewPresenterProtocol {
    
}
