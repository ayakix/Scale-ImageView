//
//  ViewController.swift
//  Scale-ImageView
//
//  Created by Ayakix on 2017/03/27.
//  Copyright © 2017年 Ayakix. All rights reserved.
//

import UIKit

fileprivate struct TransformProperty {
    private let kMaxBackgroundAlpha: CGFloat = 0.77
    private let kMinBackgroundAlpha: CGFloat = 0.4
    
    var point: CGPoint
    var scale: CGFloat
    var backgroundAlpha: CGFloat {
        didSet {
            // Round the value
            backgroundAlpha = min(kMaxBackgroundAlpha, max(kMinBackgroundAlpha, backgroundAlpha))
        }
    }
    
    init() {
        point = CGPoint(x: 0, y: 0)
        scale = 1.0
        backgroundAlpha = kMinBackgroundAlpha
    }
}

class ViewController: UIViewController {
    @IBOutlet fileprivate weak var filterView: UIView!
    @IBOutlet fileprivate weak var imageView: UIImageView!
    
    lazy fileprivate var transformProperty = TransformProperty()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Bring the expanded view to the forefront if needed
//        self.view.bringSubview(toFront: imageView)
    }
    
    @IBAction private func onPinchGesture(_ sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .changed:
            let scale = sender.scale
            if scale <= 1 {
                break
            }
            transformProperty.scale = (sender.scale - 1.0) * 0.5 + 1.0
            transform()
            // Darken the background color when scaled
            transformProperty.backgroundAlpha = (sender.scale - 1.0) * 0.8
            changeBaseViewBackgroundColor()
        case .ended, .cancelled:
            revertTransform()
        default:
            break
        }
    }
    
    @IBAction private func onPanGesture(_ sender: UIPanGestureRecognizer) {
        guard let view = sender.view else {
            return
        }
        switch sender.state {
        case .changed:
            transformProperty.point = sender.translation(in: view)
            transform()
            changeBaseViewBackgroundColor()
        case .ended, .cancelled:
            revertTransform()
        default:
            break
        }
    }
}

fileprivate extension ViewController {
    func transform() {
        imageView.transform = CGAffineTransform(translationX: transformProperty.point.x, y: transformProperty.point.y)
            .scaledBy(x: transformProperty.scale, y: transformProperty.scale)
    }
    
    func revertTransform() {
        transformProperty = TransformProperty()
        UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: { () -> Void in
            self.imageView.transform = CGAffineTransform.identity
            self.transform()
            self.filterView.backgroundColor = UIColor.clear
        }, completion: nil)
    }
    
    func changeBaseViewBackgroundColor() {
        filterView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: transformProperty.backgroundAlpha)
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
