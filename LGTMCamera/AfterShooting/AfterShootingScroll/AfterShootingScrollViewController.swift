//
//  AfterShootingScrollViewController.swift
//  LGTMCamera
//
//  Created by 山口賢登 on 2019/01/11.
//  Copyright © 2019 山口賢登. All rights reserved.
//

import UIKit

class AfterShootingScrollViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var presenter: AfterShootingScrollViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = AfterShootingScrollViewPresenter(view: self)
    }
}

extension AfterShootingScrollViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}

extension AfterShootingScrollViewController: AfterShootingScrollViewPresenterProtocol {
    
}
