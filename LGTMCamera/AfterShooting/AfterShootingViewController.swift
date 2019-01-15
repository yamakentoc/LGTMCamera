//
//  AfterShootingViewController.swift
//  LGTMCamera
//
//  Created by 山口賢登 on 2019/01/02.
//  Copyright © 2019 山口賢登. All rights reserved.
//

import UIKit
import AVFoundation
import ImageIO
import MobileCoreServices
import Gifu
import SVProgressHUD
import Photos

protocol AfterShootingDelegate: class {
    func resizeButton()
}

class AfterShootingViewController: UIViewController {

    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var bottomMenuView: UIView!
    @IBOutlet weak var adjustSpeedView: UIView!
    
    @IBOutlet weak var saveButton: UIButton!
    
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
    
    @IBAction func tapSaveButton(_ sender: UIButton) {
        makeGifImage()
    }
    
    @IBAction func tapBackButton(_ sender: UIButton) {
        timer?.invalidate()
        self.delegate?.resizeButton()
        self.dismiss(animated: true, completion: nil)
    }
    
//    @IBAction func adjustGifSpeed(_ sender: UISlider) {//画像の切り替えspeedを調整
//        timer?.invalidate()
//        frameRate = CMTimeMake(value: 1, timescale: Int32(sender.value))
//        activeTimer()
//    }
    
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
    
    //gifを保存
    func makeGifImage() {
        SVProgressHUD.show(withStatus: "saving gif")
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]//ループカウント
        let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: CMTimeGetSeconds(self.frameRate)]]//フレームレート
        let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(NSUUID().uuidString).gif")
        guard let destination = CGImageDestinationCreateWithURL(url! as CFURL, kUTTypeGIF, self.takenPhotos.count, nil) else { return } //保存先
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary?)
        DispatchQueue.global(qos: .default).async {
            for image in self.takenPhotos {
                guard let translatedImage = self.translate(image) else { return }
                CGImageDestinationAddImage(destination, translatedImage, frameProperties as CFDictionary)
            }
            if CGImageDestinationFinalize(destination) {//GIF生成後の処理
                DispatchQueue.main.async {
                    PHPhotoLibrary.shared().performChanges({//gifを保存
                        PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url!)
                    }, completionHandler: { (_, _) in
                        SVProgressHUD.setMinimumDismissTimeInterval(1.0)
                        SVProgressHUD.showSuccess(withStatus: "saved!")
                    })
                }
            } else {
                SVProgressHUD.showError(withStatus: "error!")
            }
        }
    }
    
    //UIImageからCGImageにそのまま変換すると画像の向きが保持されないから
    func translate(_ image: UIImage) -> CGImage? {
        guard let cgImage = image.cgImage else { return nil }
        ////元画像から右に90度回転(内カメラの時は反転状態に)
        let orientation: CGImagePropertyOrientation = self.isBackCamera ? .right : .leftMirrored
        let ciImage = CIImage(cgImage: cgImage).oriented(orientation)
        let ciContext = CIContext(options: nil)
        guard let cgImageFromCIImage: CGImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return nil}
        return cgImageFromCIImage
    }
}

extension AfterShootingViewController: AfterShootingViewPresenterProtocol {
    
}
