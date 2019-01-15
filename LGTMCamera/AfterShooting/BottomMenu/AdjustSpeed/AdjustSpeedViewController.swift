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

    @IBOutlet weak var adjustSpeedSlider: UISlider!
    
    var originalFrameRate: CMTime!
    var originalSliderValue: Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let afterShootingVC = self.parent as? AfterShootingViewController else { return }
        self.originalFrameRate = afterShootingVC.frameRate
        self.originalSliderValue = self.adjustSpeedSlider.value
    }
    
    @IBAction func adjustGifSpeed(_ sender: UISlider) {//画像の切り替えspeedを調整
        guard let afterShootingVC = self.parent as? AfterShootingViewController else { return }
        afterShootingVC.timer?.invalidate()
        afterShootingVC.frameRate = CMTimeMake(value: 1, timescale: Int32(sender.value))
        afterShootingVC.activeTimer()
    }
    
    @IBAction func tapDoneButton(_ sender: UIButton) {
        guard let afterShootingVC = self.parent as? AfterShootingViewController else { return }
        self.originalSliderValue = self.adjustSpeedSlider.value
        afterShootingVC.switchBottomView(tag: 0)
    }
    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        guard let afterShootingVC = self.parent as? AfterShootingViewController else { return }
        afterShootingVC.timer?.invalidate()
        afterShootingVC.frameRate = self.originalFrameRate
        afterShootingVC.activeTimer()
        afterShootingVC.switchBottomView(tag: 0)
        self.adjustSpeedSlider.value = self.originalSliderValue
    }
}
