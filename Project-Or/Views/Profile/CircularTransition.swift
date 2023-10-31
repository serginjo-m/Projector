//
//  CircularTransition.swift
//  Projector
//
//  Created by Serginjo Melnik on 19/03/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import UIKit

class CircularTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    weak var context: UIViewControllerContextTransitioning?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        context = transitionContext
        
        guard let fromVC = transitionContext.viewController(forKey: .from) as? CircleTransitionable,
              let toVC = transitionContext.viewController(forKey: .to) as? CircleTransitionable,
              let snapshot = fromVC.mainView.snapshotView(afterScreenUpdates: false) else{               transitionContext.completeTransition(false)
                  return
              }
        
        let containerView = transitionContext.containerView
        
        containerView.addSubview(snapshot)
        
        let backgroundView = UIView()
        backgroundView.frame = toVC.mainView.frame
        backgroundView.backgroundColor = fromVC.mainView.backgroundColor
        containerView.addSubview(backgroundView)
        fromVC.mainView.removeFromSuperview()
        animateOldTextOffscreen(fromView: snapshot)
        
        containerView.addSubview(toVC.mainView)
        
        animate(toView: toVC.mainView, fromTriggerButton: fromVC.profileConfigurationButton)
        animateToTextView(toTextView: toVC.contentTextView, fromTriggerButton: fromVC.profileConfigurationButton)
    }
    
    func animateOldTextOffscreen(fromView: UIView){
        
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: .curveEaseIn, animations: {
        
            fromView.center = CGPoint(x: fromView.center.x - 1300, y: fromView.center.y + 1500)
            
            fromView.transform = CGAffineTransform(scaleX: 5.0, y: 5.0)
        }, completion: nil)
        
    }
    
    func animateToTextView(toTextView: UIView, fromTriggerButton: UIButton){
        
        let originalCenter = toTextView.center
        toTextView.alpha = 0.0
        toTextView.center = fromTriggerButton.center
        toTextView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.25, delay: 0.1, options: [.curveEaseOut], animations: {
          toTextView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
          toTextView.center = originalCenter
          toTextView.alpha = 1.0
        }, completion: nil)

    }

    func animate(toView: UIView, fromTriggerButton triggerButton: UIButton) {

        let rect = CGRect(x: triggerButton.frame.origin.x, y: triggerButton.frame.origin.y, width: triggerButton.frame.width, height: triggerButton.frame.height)

        let circleMaskPathInitial = UIBezierPath(ovalIn: rect)
        let fullHeight = toView.bounds.height
        let extremePoint = CGPoint(x: triggerButton.center.x,
                                   y: triggerButton.center.y - fullHeight)
        let radius = sqrt(((extremePoint.x*extremePoint.x) * 1.2) +
                          ((extremePoint.y*extremePoint.y) * 1.2))
        
        let circleMaskPathFinal = UIBezierPath(ovalIn: triggerButton.frame.insetBy(dx: -radius, dy: -radius))
        
        
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = circleMaskPathFinal.cgPath
        toView.layer.mask = maskLayer
        
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        
        maskLayerAnimation.duration = 0.15
        maskLayerAnimation.delegate = self
        
        maskLayer.add(maskLayerAnimation, forKey: "path")
    }

    

}

extension CircularTransition: CAAnimationDelegate {
    //When this animation is complete call this whole animation a success
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        //notifying the system when the animation completes successfully.
        context?.completeTransition(true)
    }
}
