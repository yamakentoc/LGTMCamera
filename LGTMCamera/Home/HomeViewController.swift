//
//  ViewController.swift
//  LGTMCamera
//
//  Created by 山口賢登 on 2018/12/28.
//  Copyright © 2018 山口賢登. All rights reserved.
//

import UIKit
import AVFoundation
import ImageIO
import MobileCoreServices
import SwiftyGif

class HomeViewController: UIViewController {
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var snapBackView: UIVisualEffectView! {
        didSet {
            snapBackView.layer.masksToBounds = true
            snapBackView.layer.cornerRadius = snapBackView.bounds.width / 2
        }
    }
    @IBOutlet weak var snapButton: UIButton! {
        didSet {
            snapButton.layer.masksToBounds = true
            snapButton.layer.cornerRadius = snapButton.bounds.width / 2
        }
    }

    var presenter: HomeViewPresenter!
    var customAVFoundation: CustomAVFoundation!
    var circle: CAShapeLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = HomeViewPresenter(view: self)
        //customAVFoundation = CustomAVFoundation(view: self.previewView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        customAVFoundation = CustomAVFoundation(view: self.previewView)
    }
    
    @IBAction func touchDownSnapButton(_ sender: UIButton) {//連写中
        customAVFoundation.isShooting = true
        customAVFoundation.takenPhotos = []
        expandingCircleAnimation()
    }
    
    @IBAction func touchUpSnapButton(_ sender: UIButton) {//連写終了
        customAVFoundation.isShooting = false
        makeGifImage()
        //アニメーションを止める
        let layer = snapBackView.layer
        let pauseTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pauseTime
    }
    
    func expandingCircleAnimation() {
        let changedSnapButtonSize = self.view.bounds.width * 0.12
        let changedSnapBackViewSize = self.view.bounds.width * 0.29
        //snapButtonのサイズ変更
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.snapButton.frame.size = CGSize(width: changedSnapButtonSize, height: changedSnapButtonSize)
            self.snapButton.center = self.snapBackView.center
            self.snapButton.layer.cornerRadius = changedSnapButtonSize / 2
        }, completion: nil)
        //snapBackViewのサイズ変更
       UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseIn, animations: {
            self.snapBackView.frame.size = CGSize(width: changedSnapBackViewSize, height: changedSnapBackViewSize)
            self.snapBackView.center = self.snapButton.center
            self.snapBackView.layer.cornerRadius = changedSnapBackViewSize / 2
        }, completion: { _ -> Void in
            self.drawCircle(targetView: self.snapBackView)
        })
    }
    
    //撮影中に表示されるprogressCircle
    func drawCircle(targetView: UIView) {
        let lineWidth: CGFloat = 6// ゲージ幅
        let viewScale: CGFloat = targetView.frame.size.width// 描画領域のwidth
        let radius: CGFloat = viewScale - lineWidth//円のサイズ
        circle.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: radius, height: radius), cornerRadius: radius / 2).cgPath
        circle.position = CGPoint(x: lineWidth / 2, y: lineWidth / 2)
        circle.fillColor = UIColor.clear.cgColor
        circle.strokeColor = UIColor.red.cgColor
        circle.lineWidth = lineWidth//線の幅
        targetView.layer.addSublayer(circle)
        drawCircleAnimation(fromValue: 0.0, toValue: 1.0, duration: 2.0, repeatCount: 1.0, flag: false)
    }
    
    func drawCircleAnimation(fromValue: CGFloat, toValue: CGFloat, duration: TimeInterval, repeatCount: Float, flag: Bool) {
        let drawAnimation = CABasicAnimation(keyPath: "strokeEnd")
        drawAnimation.duration = duration// アニメーション間隔
        drawAnimation.repeatCount = repeatCount
        drawAnimation.fromValue = fromValue// 起点と目標点の変化比率を設定 (0.0 〜 1.0)
        drawAnimation.toValue = toValue
        drawAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        drawAnimation.isRemovedOnCompletion = false// アニメ完了時の描画を保持
        drawAnimation.fillMode = CAMediaTimingFillMode.forwards
        drawAnimation.autoreverses = flag// 逆再生の指定
        circle.add(drawAnimation, forKey: "updateGageAnimation")
    }
    
    func makeGifImage() {
        let frameRate = CMTimeMake(value: 1, timescale: 60)//gifの速さ(timescaleが高いほど早い)
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]//ループカウント
        let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: CMTimeGetSeconds(frameRate)]]//フレームレート
        let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(NSUUID().uuidString).gif")
        guard let destination = CGImageDestinationCreateWithURL(url! as CFURL, kUTTypeGIF, customAVFoundation.takenPhotos.count, nil) else { //保存先
            print("CGImageDestinationの作成に失敗")
            return
        }
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary?)
        DispatchQueue.global(qos: .default).async {
            for image in self.customAVFoundation.takenPhotos {
                guard let translatedImage = self.translate(image) else { return }
                CGImageDestinationAddImage(destination, translatedImage, frameProperties as CFDictionary)
            }
            if CGImageDestinationFinalize(destination) {//GIF生成後の処理
                DispatchQueue.main.async {
                    let imageView = UIImageView(gifURL: url, loopCount: -1)
                    imageView.frame = self.view.bounds
                    self.view.addSubview(imageView)
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

extension HomeViewController: HomeViewPresenterProtocol {
    
}
