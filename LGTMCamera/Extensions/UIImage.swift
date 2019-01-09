//
//  UIImage.swift
//  LGTMCamera
//
//  Created by 山口賢登 on 2019/01/09.
//  Copyright © 2019 山口賢登. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func croppingToCenterSquare() -> UIImage {
        let cgImage = self.cgImage!
        var newWidth = CGFloat(cgImage.width)
        var newHeight = CGFloat(cgImage.height)
        if newWidth > newHeight {
            newWidth = newHeight
        } else {
            newHeight = newWidth
        }
        let x = (CGFloat(cgImage.width) - newWidth) / 2
        let y = (CGFloat(cgImage.height) - newHeight) / 2
        let rect = CGRect(x: x, y: y, width: newWidth, height: newHeight)
        let croppedCGImage = cgImage.cropping(to: rect)!
        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
}
