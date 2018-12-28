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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = HomeViewPresenter(view: self)
        initVideo()
    }
}

extension HomeViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func initVideo() {
        //セッションのインスタンス生成
        let captureSession = AVCaptureSession()
        //入力(背面カメラ)
        let videoDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                                                  for: AVMediaType.video, position: .back)
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
        
    }
}

extension HomeViewController: HomeViewPresenterProtocol {

}
