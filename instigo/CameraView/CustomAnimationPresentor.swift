//
//  CustomAnimationPresentor.swift
//  instigo
//
//  Created by Omar Khaled on 27/04/2022.
//

import UIKit


class CustomAnimationPresentor:NSObject,UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let toView  = transitionContext.view(forKey: .to) else {return}
        guard let fromView  = transitionContext.view(forKey: .from) else {return}
        
        containerView.addSubview(toView)
        
        
        toView.frame = CGRect(x: -toView.frame.width, y: 0, width: toView.frame.width, height: toView.frame.height)
        
        
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
            
            toView.frame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
            fromView.frame = CGRect(x: fromView.frame.width, y: 0, width: toView.frame.width, height: toView.frame.height)
            
            
        } completion: { _ in
            transitionContext.completeTransition(true)
        }

    }
     
}
