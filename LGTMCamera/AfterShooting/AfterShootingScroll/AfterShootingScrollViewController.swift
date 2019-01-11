//
//  AfterShootingScrollViewController.swift
//  LGTMCamera
//
//  Created by 山口賢登 on 2019/01/11.
//  Copyright © 2019 山口賢登. All rights reserved.
//

import UIKit
import ASHorizontalScrollView

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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellPortrait"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        cell?.selectionStyle = .none
        let horizontalScrollView: ASHorizontalScrollView = ASHorizontalScrollView(frame: self.tableView.frame)
        horizontalScrollView.arrangeType = .byNumber
        //leftMargin: 左から何ポイント離すか numberOf~: 画面に初期で何個表示するか
        horizontalScrollView.defaultMarginSettings = MarginSettings(leftMargin: 10,
                                                                    numberOfItemsPerScreen: 4)
        let squareSize = self.tableView.bounds.height * 0.3
        horizontalScrollView.uniformItemSize = CGSize(width: squareSize, height: squareSize)
        horizontalScrollView.setItemsMarginOnce()
        for _ in 1...6 {
            let button = UIButton(frame: CGRect.zero)
            button.backgroundColor = UIColor.red
            horizontalScrollView.addItem(button)
        }
        cell?.contentView.addSubview(horizontalScrollView)
        horizontalScrollView.translatesAutoresizingMaskIntoConstraints = false
        cell?.contentView.addConstraint(NSLayoutConstraint(item: horizontalScrollView, attribute: NSLayoutConstraint.Attribute.left,
                                                           relatedBy: NSLayoutConstraint.Relation.equal, toItem: cell!.contentView,
                                                           attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0))
        cell?.contentView.addConstraint(NSLayoutConstraint(item: horizontalScrollView, attribute: NSLayoutConstraint.Attribute.top,
                                                           relatedBy: NSLayoutConstraint.Relation.equal, toItem: cell!.contentView,
                                                           attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0))
        cell?.contentView.addConstraint(NSLayoutConstraint(item: horizontalScrollView, attribute: NSLayoutConstraint.Attribute.height,
                                                           relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil,
                                                           attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.tableView.bounds.height))
        cell?.contentView.addConstraint(NSLayoutConstraint(item: horizontalScrollView, attribute: NSLayoutConstraint.Attribute.width,
                                                           relatedBy: NSLayoutConstraint.Relation.equal, toItem: cell!.contentView,
                                                           attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0))
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.bounds.height
    }
}

extension AfterShootingScrollViewController: AfterShootingScrollViewPresenterProtocol {
    
}
