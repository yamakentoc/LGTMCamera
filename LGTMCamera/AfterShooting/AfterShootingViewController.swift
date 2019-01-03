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
import SwiftyGif
import SVProgressHUD

class AfterShootingViewController: UIViewController {

    var presenter: AfterShootingViewPresenter!
    var takenPhotos: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = AfterShootingViewPresenter(view: self)
        SVProgressHUD.show(withStatus: "Generating gif")
        makeGifImage()
    }

    func makeGifImage() {
        let frameRate = CMTimeMake(value: 1, timescale: 60)//gifの速さ(timescaleが高いほど早い)
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]//ループカウント
        let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: CMTimeGetSeconds(frameRate)]]//フレームレート
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
                    let imageView = UIImageView(gifURL: url, loopCount: -1)
                    imageView.frame = self.view.bounds
                    self.view.addSubview(imageView)
                    SVProgressHUD.dismiss()
                }
            } else {
                print("GIF生成に失敗")
            }
        }
    }
    
    //UIImageからCGImageにそのまま変換すると画像の向きが保持されないから
    func translate(_ image: UIImage) -> CGImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage).oriented(CGImagePropertyOrientation.right)//元画像から右に90度回転
        let ciContext = CIContext(options: nil)
        guard let cgImageFromCIImage: CGImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return nil}
        return cgImageFromCIImage
    }
}

extension AfterShootingViewController: AfterShootingViewPresenterProtocol {
    
}
