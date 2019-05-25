//
//  PresentingSpringAnimator.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 5/18/14.
//  Copyright (c) 2014 Sandeep Jangity. All rights reserved.
//

#import "PresentingSpringAnimator.h"

@interface PresentingSpringAnimator ()

@property (nonatomic) TransitioningDirection transitioningDirection;

@end

@implementation PresentingSpringAnimator

- (id)initWithTransitioningDirection:(TransitioningDirection)transitioningDirection
{
    self = [super init];
    if (self) {
        self.transitioningDirection = transitioningDirection;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 1.0f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect fromVCFrame = [transitionContext initialFrameForViewController:fromVC];
    
    CGRect finalFrame = CGRectMake(20, 20, CGRectGetWidth(fromVCFrame) - 40, CGRectGetHeight(fromVCFrame) - 40);
    
    CGRect initialFrame = [self initialFrameFromFinalFrame:finalFrame inTransitionContext:transitionContext];
    
    toVC.view.frame = initialFrame;
    [[transitionContext containerView] addSubview:toVC.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0f
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0.6f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         toVC.view.frame = finalFrame;
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                     }];
}

- (CGRect)initialFrameFromFinalFrame:(CGRect)finalFrame inTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext
{
    CGRect initialFrame;
    
    switch (self.transitioningDirection) {
        case TransitioningDirectionUp:
            initialFrame = CGRectOffset(finalFrame, 0, -CGRectGetHeight(transitionContext.containerView.frame));
            break;
        case TransitioningDirectionLeft:
            initialFrame = CGRectOffset(finalFrame, -CGRectGetWidth(transitionContext.containerView.frame), 0);
            break;
        case TransitioningDirectionDown:
            initialFrame = CGRectOffset(finalFrame, 0, CGRectGetHeight(transitionContext.containerView.frame));
            break;
        case TransitioningDirectionRight:
            initialFrame = CGRectOffset(finalFrame, CGRectGetWidth(transitionContext.containerView.frame), 0);
            break;
    }
    
    return initialFrame;
}

@end
