//
//  CircularTransition.swift
//  Projector
//
//  Created by Serginjo Melnik on 19/03/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import UIKit
//protocol defines the information you’ll need from each view controller in order to successfully animate things
protocol CircleTransitionable{
    var transitionButton: UIButton {get}//trigger button
    var contentTextView: UITextView {get}//text to animate
    var mainView: UIView {get}//whole view controller shapshot that will be animated
}

class CircularTransition: NSObject, UIViewControllerAnimatedTransitioning {
    //reference to the context object, use for noti
    weak var context: UIViewControllerContextTransitioning?
    //duration
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        context = transitionContext
        
        guard let fromVC = transitionContext.viewController(forKey: .from) as? CircleTransitionable,
              let toVC = transitionContext.viewController(forKey: .to) as? CircleTransitionable,
              //Snapshot views are a really useful way to quickly grab a disposable copy of a view for animations
              let snapshot = fromVC.mainView.snapshotView(afterScreenUpdates: false) else{               transitionContext.completeTransition(false)
                  return
              }
//        like your scratchpad for adding and removing views on the way to your final destination
        let containerView = transitionContext.containerView
        //add snapshot
        containerView.addSubview(snapshot)
        
        let backgroundView = UIView()
        backgroundView.frame = toVC.mainView.frame
        backgroundView.backgroundColor = fromVC.mainView.backgroundColor
        containerView.addSubview(backgroundView)
        fromVC.mainView.removeFromSuperview()
        animateOldTextOffscreen(fromView: snapshot)
        //adds final view to the containerView
        containerView.addSubview(toVC.mainView)
        //implement the animation
        animate(toView: toVC.mainView, fromTriggerButton: fromVC.transitionButton)
        animateToTextView(toTextView: toVC.contentTextView, fromTriggerButton: fromVC.transitionButton)
    }
    
    func animateOldTextOffscreen(fromView: UIView){
        //define an animation that will take 0.25 seconds to complete and eases into its animation curve
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: .curveEaseIn, animations: {
            //animate the view’s center down and to the left offscreen.
            fromView.center = CGPoint(x: fromView.center.x - 1300, y: fromView.center.y + 1500)
            //The view is blown up by 5x so the text seems to grow along with the circle
            fromView.transform = CGAffineTransform(scaleX: 5.0, y: 5.0)
        }, completion: nil)
        
    }
    
    func animateToTextView(toTextView: UIView, fromTriggerButton: UIButton){
        //setting the starting state of toTextView.
        //set its alpha to 0, center it with the trigger button, and scale it to 1/10th its normal size.
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
    //the actual circular transition where the new view controller animates in from the button’s position.
    func animate(toView: UIView, fromTriggerButton triggerButton: UIButton) {
        //rect similar to the button’s frame, but with an equal width and height
        let rect = CGRect(x: triggerButton.frame.origin.x, y: triggerButton.frame.origin.y, width: triggerButton.frame.width, height: triggerButton.frame.height)
        //bezier path oval from the rect which results in a circle
        let circleMaskPathInitial = UIBezierPath(ovalIn: rect)
        //create a circle representing the ending state of the animation
        // Defines a point that’s the full screen’s height above the top of the screen
        let fullHeight = toView.bounds.height
        let extremePoint = CGPoint(x: triggerButton.center.x,
                                   y: triggerButton.center.y - fullHeight)
        // Calculates the radius of your new circle by using the Pythagorean Theorem: a² + b² = c².
        let radius = sqrt((extremePoint.x*extremePoint.x) +
                          (extremePoint.y*extremePoint.y))
        // Creates your new bezier path by taking the current frame of the circle and “insetting” it by a negative amount in both directions, thus pushing it out to go fully beyond the bounds of the screen in both directions.
        let circleMaskPathFinal = UIBezierPath(ovalIn: triggerButton.frame.insetBy(dx: -radius,
                                                                                   dy: -radius))
        //This creates a CAShapeLayer layer and sets its path to the circular bezier path.
        let maskLayer = CAShapeLayer()
        //maskLayer is then used as a mask for the destination view.
        maskLayer.path = circleMaskPathFinal.cgPath
        toView.layer.mask = maskLayer
        //create an animation object and tell it that the property that will be animated is the path property. This means you’ll animate the rendered shape
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        //set the from and to-values for this animation
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        //duration
        maskLayerAnimation.duration = 0.15
        maskLayerAnimation.delegate = self
        // animation object all set up, so just add it to the maskLayer.
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
