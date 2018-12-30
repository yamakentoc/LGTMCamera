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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = HomeViewPresenter(view: self)
        initVideo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initBlurEffect()
    }
    
    @IBAction func touchDownSnapButton(_ sender: UIButton) {//連写中
        isPushing = true
        takenPhotos = []
    }
    
    @IBAction func touchUpSnapButton(_ sender: UIButton) {//連写終了
        isPushing = false
        print(takenPhotos.count)
    }
    
    func initBlurEffect() {
        let blurEffect = UIBlurEffect(style: .light)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        let size = self.view.bounds.width * 0.22
        visualEffectView.frame.size = CGSize(width: size, height: size)
        visualEffectView.center = self.snapButton.center
        visualEffectView.layer.masksToBounds = true
        visualEffectView.layer.cornerRadius = visualEffectView.bounds.width / 2
        self.view.addSubview(visualEffectView)
        self.view.bringSubviewToFront(self.snapButton)
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
