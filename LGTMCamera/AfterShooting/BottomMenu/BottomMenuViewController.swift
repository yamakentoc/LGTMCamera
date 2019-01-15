//
//  BottomMenuViewController.swift
//  LGTMCamera
//
//  Created by 山口賢登 on 2019/01/11.
//  Copyright © 2019 山口賢登. All rights reserved.
//

import UIKit
import ASHorizontalScrollView
import SVProgressHUD
import Photos
import ImageIO
import MobileCoreServices

class BottomMenuViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    var presenter: BottomMenuViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = BottomMenuViewPresenter(view: self)
    }
    
    @IBAction func tapSaveButton() {
        guard let afterShootingVC = self.parent as? AfterShootingViewController else { return }
        SVProgressHUD.show(withStatus: "saving gif")
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]//ループカウント
        let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: CMTimeGetSeconds(afterShootingVC.frameRate)]]//フレームレート
        let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(NSUUID().uuidString).gif")
        guard let destination = CGImageDestinationCreateWithURL(url! as CFURL, kUTTypeGIF, afterShootingVC.takenPhotos.count, nil) else { return } //保存先
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary?)
        DispatchQueue.global(qos: .default).async {
            for image in afterShootingVC.takenPhotos {
                guard let translatedImage = self.translate(image) else { return }
                CGImageDestinationAddImage(destination, translatedImage, frameProperties as CFDictionary)
            }
            if CGImageDestinationFinalize(destination) {//GIF生成後の処理
                DispatchQueue.main.async {
                    PHPhotoLibrary.shared().performChanges({//gifを保存
                        PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url!)
                    }, completionHandler: { (_, _) in
                        SVProgressHUD.setMinimumDismissTimeInterval(1.0)
                        SVProgressHUD.showSuccess(withStatus: "saved!")
                    })
                }
            } else {
                SVProgressHUD.showError(withStatus: "error!")
            }
        }
    }
    
    //UIImageからCGImageにそのまま変換すると画像の向きが保持されないから
    func translate(_ image: UIImage) -> CGImage? {
        guard let cgImage = image.cgImage, let afterShootingVC = self.parent as? AfterShootingViewController else { return nil }
        ////元画像から右に90度回転(内カメラの時は反転状態に)
        let orientation: CGImagePropertyOrientation = afterShootingVC.isBackCamera ? .right : .leftMirrored
        let ciImage = CIImage(cgImage: cgImage).oriented(orientation)
        let ciContext = CIContext(options: nil)
        guard let cgImageFromCIImage: CGImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return nil}
        return cgImageFromCIImage
    }
    
    @objc func selectBottomMenu(_ sender: UIButton) {
        guard let afterShootingVC  = self.parent as? AfterShootingViewController else { return }
        afterShootingVC.switchBottomView(tag: sender.tag)
    }
}

extension BottomMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellPortrait"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        cell?.selectionStyle = .none
        let horizontalScrollView: ASHorizontalScrollView = ASHorizontalScrollView(frame: self.tableView.frame)
        horizontalScrollView.arrangeType = .byNumber
        //leftMargin: 左から何ポイント離すか numberOf~: 画面に初期で何個表示するか
        horizontalScrollView.defaultMarginSettings = MarginSettings(leftMargin: 10,
                                                                    numberOfItemsPerScreen: 4)
        let squareSize = self.tableView.bounds.height * 0.3
        horizontalScrollView.uniformItemSize = CGSize(width: squareSize, height: squareSize)
        horizontalScrollView.setItemsMarginOnce()
        for i in 1...6 {
            let button = UIButton(frame: CGRect.zero)
            button.backgroundColor = UIColor.red
            button.setTitle("hoge", for: .normal)
            button.tag = i
            button.addTarget(self, action: #selector(self.selectBottomMenu(_:)), for: .touchUpInside)
            horizontalScrollView.addItem(button)
        }
        cell?.contentView.addSubview(horizontalScrollView)
        horizontalScrollView.translatesAutoresizingMaskIntoConstraints = false
        cell?.contentView.addConstraint(NSLayoutConstraint(item: horizontalScrollView, attribute: NSLayoutConstraint.Attribute.left,
                                                           relatedBy: NSLayoutConstraint.Relation.equal, toItem: cell!.contentView,
                                                           attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0))
        cell?.contentView.addConstraint(NSLayoutConstraint(item: horizontalScrollView, attribute: NSLayoutConstraint.Attribute.top,
                                                           relatedBy: NSLayoutConstraint.Relation.equal, toItem: cell!.contentView,
                                                           attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0))
        cell?.contentView.addConstraint(NSLayoutConstraint(item: horizontalScrollView, attribute: NSLayoutConstraint.Attribute.height,
                                                           relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil,
                                                           attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.tableView.bounds.height))
        cell?.contentView.addConstraint(NSLayoutConstraint(item: horizontalScrollView, attribute: NSLayoutConstraint.Attribute.width,
                                                           relatedBy: NSLayoutConstraint.Relation.equal, toItem: cell!.contentView,
                                                           attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0))
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.bounds.height
    }
}

extension BottomMenuViewController: BottomMenuViewPresenterProtocol {
    
}
