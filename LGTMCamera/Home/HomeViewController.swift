//
//  ViewController.swift
//  LGTMCamera
//
//  Created by 山口賢登 on 2018/12/28.
//  Copyright © 2018 山口賢登. All rights reserved.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController {
    
    @IBOutlet weak var previewImageView: UIImageView!
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
    var takenPhotos: [UIImage] = []
    var isPushing = false //連写中
    var captureCounter = 0
    var circle: CAShapeLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = HomeViewPresenter(view: self)
        initVideo()
    }
    
    @IBAction func touchDownSnapButton(_ sender: UIButton) {//連写中
        isPushing = true
        takenPhotos = []
        expandingCircleAnimation()
    }
    
    @IBAction func touchUpSnapButton(_ sender: UIButton) {//連写終了
        isPushing = false
        print(takenPhotos.count)
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
}

extension HomeViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func initVideo() {
        let captureSession = AVCaptureSession() //セッションのインスタンス生成
        let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)//入力(背面カメラ)
        videoDevice?.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 30)
        guard let videoInput = try? AVCaptureDeviceInput.init(device: videoDevice!) else { return }
        captureSession.addInput(videoInput)
        let videoDataOutput = AVCaptureVideoDataOutput()//出力(ビデオデータ)
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_32BGRA)] as? [String: Any]//ピクセルフォーマット(32bit BGRA)
        videoDataOutput.alwaysDiscardsLateVideoFrames = true//キューのブロック中に新しいフレームが来たら削除する
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)//フレームをキャプチャするためのキューを指定
        captureSession.addOutput(videoDataOutput)
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080//クオリティ(1920*1080ピクセル)
        let videoLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)//プレビュー
        videoLayer.frame = self.view.bounds
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewImageView.layer.addSublayer(videoLayer)
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()//セッションの開始
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if captureCounter % 3 == 0, isPushing { // 1/10秒だけ処理する
            guard let image = presenter.imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
            takenPhotos.append(image)
        }
        captureCounter += 1
    }
}

extension HomeViewController: HomeViewPresenterProtocol {
    
}
