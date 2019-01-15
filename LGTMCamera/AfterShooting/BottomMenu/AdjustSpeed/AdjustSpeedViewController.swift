//
//  AdjustSpeedViewController.swift
//  LGTMCamera
//
//  Created by 山口賢登 on 2019/01/15.
//  Copyright © 2019 山口賢登. All rights reserved.
//

import UIKit
import Photos

class AdjustSpeedViewController: UIViewController {

    var afterShootingVC: AfterShootingViewController! {
        didSet {
            afterShootingVC = self.parent as? AfterShootingViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func adjustGifSpeed(_ sender: UISlider) {//画像の切り替えspeedを調整
        afterShootingVC.timer?.invalidate()
        afterShootingVC.frameRate = CMTimeMake(value: 1, timescale: Int32(sender.value))
        afterShootingVC.activeTimer()
    }
    
}
