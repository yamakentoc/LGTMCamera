//
//  HomeViewPresenter.swift
//  LGTMCamera
//
//  Created by 山口賢登 on 2018/12/28.
//  Copyright © 2018 山口賢登. All rights reserved.
//

import UIKit
import AVFoundation

protocol HomeViewPresenterProtocol: class {
    
}

class HomeViewPresenter: NSObject {
    
    private let view: HomeViewPresenterProtocol
    
    init(view: HomeViewPresenterProtocol) {
        self.view = view
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
        let image = UIImage(cgImage: imageRef, scale: 1.0, orientation: UIImage.Orientation.right)
        //イメージバッファのアンロック
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        return image
    }
    
}
