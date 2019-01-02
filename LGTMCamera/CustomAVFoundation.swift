//
//  CustomAVFoundation.swift
//  LGTMCamera
//
//  Created by 山口賢登 on 2019/01/02.
//  Copyright © 2019 山口賢登. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class CustomAVFoundation: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var view: UIView?
    var takenPhotos: [UIImage] = []
    var isPushing = false//連写中
    var captureCounter = 0
    
    init(view: UIView) {
        super.init()
        self.view = view
        initialize()
    }
    
    func initialize() {
        let captureSession = AVCaptureSession()//セッションのインスタンス生成
        //入力(背面カメラ)
        let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)
        //videoDevice?.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 30)
        guard let videoInput = try? AVCaptureDeviceInput.init(device: videoDevice!) else { return }
        captureSession.addInput(videoInput)
        //出力(ビデオデータ)
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_32BGRA)] as? [String: Any]//ピクセルフォーマット(32bit BGRA)
        self.setMaxFps()
        videoDataOutput.alwaysDiscardsLateVideoFrames = true//キューのブロック中に新しいフレームが来たら削除する
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)//フレームをキャプチャするためのキューを指定
        captureSession.addOutput(videoDataOutput)
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080//クオリティ(1920*1080ピクセル)
        //プレビュー
        let videoLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        videoLayer.frame = self.view!.bounds
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view!.layer.addSublayer(videoLayer)
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()//セッションの開始
        }
    }
    
    func setMaxFps() {
        
    }
    
    func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        //イメージバッファのロック
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        //画像情報を取得
        let base = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
        let bytesPerRow = UInt(CVPixelBufferGetBytesPerRow(imageBuffer))
        let width = UInt(CVPixelBufferGetWidth(imageBuffer))
        let height = UInt(CVPixelBufferGetHeight(imageBuffer))
        //ビットマップコンテキスト作成
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitsPerCompornent = 8
        let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue) as UInt32)
        guard let newContext = CGContext(data: base, width: Int(width), height: Int(height), bitsPerComponent: Int(bitsPerCompornent), bytesPerRow: Int(bytesPerRow), space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else { return nil }
        //画像生成
        guard let imageRef = newContext.makeImage() else { return nil }
        let image = UIImage(cgImage: imageRef, scale: 1.0, orientation: UIImage.Orientation.up)
        //イメージバッファのアンロック
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        return image
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // if captureCounter % 3 == 0, isPushing { // 1/10秒だけ処理する
        if isPushing {
            guard let image = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
            takenPhotos.append(image)
        }
        captureCounter += 1
    }
}
