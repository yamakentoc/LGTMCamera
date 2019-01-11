//
//  ViewController.swift
//  LGTMCamera
//
//  Created by 山口賢登 on 2018/12/28.
//  Copyright © 2018 山口賢登. All rights reserved.
//

import UIKit
import AVFoundation

class ShootingViewController: UIViewController {
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var snapBackView: UIView! {
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

    var presenter: ShootingViewPresenter!
    var customAVFoundation: CustomAVFoundation!
    var circle: CAShapeLayer = CAShapeLayer()
    
    var isBackCamera = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ShootingViewPresenter(view: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        customAVFoundation = CustomAVFoundation(view: self.previewView)
        customAVFoundation.sessionSetup(reset: false, isBackCamera: self.isBackCamera)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //メモリ解放
        customAVFoundation.captureSession.stopRunning()
        customAVFoundation.captureSession.outputs.forEach {
            customAVFoundation.captureSession.removeOutput($0)
        }
        customAVFoundation.captureSession.inputs.forEach {
            customAVFoundation.captureSession.removeInput($0)
        }
        customAVFoundation.captureSession = nil
        customAVFoundation.videoDevice = nil
        customAVFoundation = nil
        //アニメーションを取り除く
        circle.removeAllAnimations()
        circle.removeFromSuperlayer()
    }
    
    @IBAction func touchDownSnapButton(_ sender: UIButton) {//連写中
        customAVFoundation.isShooting = true
        customAVFoundation.takenPhotos = []
        expandingCircleAnimation()
    }
    
    @IBAction func touchUpSnapButton(_ sender: UIButton) {//連写終了
        customAVFoundation.isShooting = false
        //アニメーションを止める
        let pauseTime = circle.convertTime(CACurrentMediaTime(), from: nil)
        circle.speed = 0.0
        circle.timeOffset = pauseTime
        guard let afterShootingVC = R.storyboard.afterShootingViewController().instantiateInitialViewController() as? AfterShootingViewController else { return }
        afterShootingVC.delegate = self
        afterShootingVC.takenPhotos = customAVFoundation.takenPhotos
        self.present(afterShootingVC, animated: true, completion: nil)
    }
    
    @IBAction func tapSwitchButton(_ sender: UIButton) {
        self.isBackCamera = !self.isBackCamera
        customAVFoundation.sessionSetup(reset: true, isBackCamera: self.isBackCamera)
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
            print("")
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
        drawCircleAnimation(fromValue: 0.0, toValue: 1.0, duration: 10.0, repeatCount: 1.0, flag: false)
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

extension ShootingViewController: AfterShootingDelegate {
    func resizeButton() {
        //アニメーションの状態を戻し再開可能に
        circle.speed = 1.0
        circle.timeOffset = 0.0
        //ボタンのサイズを元に戻す
        let originalSnapButtonSize = self.view.bounds.width * 0.16//snapButtonの元のサイズ
        let originalSnapBackViewSize = self.view.bounds.width * 0.22//snapBackViewの元のサイズ
        self.snapButton.frame.size = CGSize(width: originalSnapButtonSize, height: originalSnapButtonSize)
        self.snapButton.center = self.snapBackView.center
        self.snapButton.layer.cornerRadius = originalSnapButtonSize / 2
        self.snapBackView.frame.size = CGSize(width: originalSnapBackViewSize, height: originalSnapBackViewSize)
        self.snapBackView.center = self.snapButton.center
        self.snapBackView.layer.cornerRadius = originalSnapBackViewSize / 2
    }
}

extension ShootingViewController: ShootingViewPresenterProtocol {
    
}
