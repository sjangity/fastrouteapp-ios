//
//  BaseTransitionAnimator.swift
//  FastRoute
//
//  Created by apple on 8/23/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import UIKit

class BaseTransitionAnimator : NSObject, UIViewControllerAnimatedTransitioning {

    enum PresentationMode {
        case Presenting, Dismissing
    }
    var duration     : NSTimeInterval = 1.0
    var mode         : PresentationMode = .Presenting

    init(duration: NSTimeInterval, mode: PresentationMode) {
        self.duration = duration
        self.mode = mode
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return duration
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        // stub - must be overriden by inheritor
    }
}
