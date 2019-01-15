//
//  AfterShootingViewController.swift
//  LGTMCamera
//
//  Created by 山口賢登 on 2019/01/02.
//  Copyright © 2019 山口賢登. All rights reserved.
//

import UIKit
import AVFoundation
import Gifu
import Photos

protocol AfterShootingDelegate: class {
    func resizeButton()
}

class AfterShootingViewController: UIViewController {

    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var bottomMenuView: UIView!
    @IBOutlet weak var adjustSpeedView: UIView!
        
    var presenter: AfterShootingViewPresenter!
    weak var delegate: AfterShootingDelegate?
    var containerViews: [UIView] = []
    var takenPhotos: [UIImage] = []
    var frameRate = CMTimeMake(value: 1, timescale: 12)//gifの速さ(timescaleが高いほど早い)
    var timer: Timer?
    var switchCount = 0//画像を切り替えるためのカウント
    var isBackCamera = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = AfterShootingViewPresenter(view: self)
        containerViews = [bottomMenuView, adjustSpeedView]
        self.gifImageView.image = takenPhotos.first
        activeTimer()
    }
    
    @IBAction func tapBackButton(_ sender: UIButton) {
        timer?.invalidate()
        self.delegate?.resizeButton()
        self.dismiss(animated: true, completion: nil)
    }
    
    func activeTimer() {//timerの生成
        let cmTime = CMTimeGetSeconds(frameRate)
        timer = Timer.scheduledTimer(timeInterval: cmTime, target: self, selector: #selector(switchImage), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .tracking)
    }
    
    @objc func switchImage() {//画像を切り替える
        switchCount = switchCount >= takenPhotos.count ? 0 : switchCount
        self.gifImageView.image = takenPhotos[switchCount]
        switchCount += 1
    }
    
    func switchBottomView(tag: Int) {
        self.view.bringSubviewToFront(containerViews[tag])
    }
}

extension AfterShootingViewController: AfterShootingViewPresenterProtocol {
    
}
