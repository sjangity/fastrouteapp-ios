//
//  ExpandingTransitionAnimator.swift
//  FastRoute
//
//  Created by apple on 8/23/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import UIKit

class ExpandingTransitionAnimator: BaseTransitionAnimator {
    enum ExpansionMode {
        case Basic, WithFadingImage
    }

    var image : UIImage? = nil

    override init(duration: NSTimeInterval, mode: PresentationMode) {
        super.init(duration: duration, mode: mode)
    }

    override func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        var fromVC             = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        var toVC               = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        var fromView           = fromVC.view
        var toView             = toVC.view
        var containerView      = transitionContext.containerView()
        var duration           = transitionDuration(transitionContext)
        var initialFrame       = transitionContext.initialFrameForViewController(fromVC)

        var imageView : UIImageView?
        if image != nil {
//            imageView = UIImageView(image: image!.crop(CGPointMake(0, 0),  size: toView.frame.size))

        }
        if (mode == .Presenting) {  
                toView.transform = CGAffineTransformMakeScale(0.05, 0.05)
               var originalCenter = toView.center
                containerView.addSubview(toView)
                if imageView != nil {
                    imageView!.transform = CGAffineTransformMakeScale(0.05, 0.05);
                    containerView.addSubview(imageView!)
                }

                UIView.animateWithDuration(duration,
                    delay:0.0,
                    options:.CurveEaseInOut,
                    animations: {
                        if imageView != nil {
                            imageView!.alpha = 0.0
                            imageView!.transform =  CGAffineTransformMakeScale(1.0, 1.0)
                        }
                        toView.transform =  CGAffineTransformMakeScale(1.0, 1.0)
                        toView.center = originalCenter
                    },
                    completion: { _ in
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                })
        } else { // dismissing
            UIView.animateWithDuration(duration,
                animations: {
                    fromView.transform = CGAffineTransformMakeScale(0.05, 0.05)
                    fromView.center = toView.center
                },
                completion: { _ in
                    fromView.removeFromSuperview()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            })
        }
    }
}
