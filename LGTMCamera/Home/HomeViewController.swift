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
    @IBOutlet weak var snapButton: UIButton!
    
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
        visualEffectView.frame = self.snapButton.frame
        visualEffectView.center = self.snapButton.center
        visualEffectView.layer.masksToBounds = true
        visualEffectView.layer.cornerRadius = visualEffectView.bounds.width / 2
        self.view.addSubview(visualEffectView)
        self.view.bringSubviewToFront(snapButton)
    }
    
}

extension HomeViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func initVideo() {
        //セッションのインスタンス生成
        let captureSession = AVCaptureSession()
        //入力(背面カメラ)
        let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)
        videoDevice?.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 30)
        guard let videoInput = try? AVCaptureDeviceInput.init(device: videoDevice!) else { return }
        captureSession.addInput(videoInput)
        //出力(ビデオデータ)
        let videoDataOutput = AVCaptureVideoDataOutput()
        //ピクセルフォーマット(32bit BGRA)
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_32BGRA)] as? [String: Any]
        //キューのブロック中に新しいフレームが来たら削除する
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        //フレームをキャプチャするためのキューを指定
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        captureSession.addOutput(videoDataOutput)
        //クオリティ(1920*1080ピクセル)
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        //プレビュー
        let videoLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        videoLayer.frame = self.view.bounds//previewImageView.bounds
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewImageView.layer.addSublayer(videoLayer)
        //セッションの開始
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
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
