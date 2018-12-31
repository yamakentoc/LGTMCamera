//
//  UIColor.swift
//  LGTMCamera
//
//  Created by 山口賢登 on 2018/12/30.
//  Copyright © 2018 山口賢登. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(_ red: Int, _ green: Int, _ blue: Int, _ alpha: Int = 255) {
        let rgba = [red, green, blue, alpha].map { i -> CGFloat in
            switch i {
            case let i where i < 0:
                return 0
            case let i where i > 255:
                return 1
            default:
                return CGFloat(i) / 255
            }
        }
        self.init(red: rgba[0], green: rgba[1], blue: rgba[2], alpha: rgba[3])
    }
}
