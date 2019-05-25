//
//  SpringTransitioningDelegate.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 5/18/14.
//  Copyright (c) 2014 Sandeep Jangity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!

 @typedef NS_ENUM (NSUInteger, TransitioningDirection)

 @abstract
 View Transition animation style.

 @discussion

 */
typedef NS_ENUM(NSInteger, TransitioningDirection) {
    /*! transition up */
    TransitioningDirectionUp = 0,
    /*! transition left */
    TransitioningDirectionLeft = 1,
    /*! transition down */
    TransitioningDirectionDown = 2,
    /*! transition right */
    TransitioningDirectionRight = 3
};

#define kTransitionDirectionCount 4

@class SpringTransitioningDelegate;

@protocol TransitioningDelegateAnimator <NSObject>

- (id)initWithTransitioningDirection:(TransitioningDirection)transitioningDirection;

@end

@interface SpringTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) UIViewController *delegate;
@property (nonatomic, retain) UIPercentDrivenInteractiveTransition *interactiveTransition;
@property TransitioningDirection transitioningDirection;
@property BOOL interactive;

- (id)initWithDelegate:(UIViewController *)delegate;
- (void)presentViewController:(UIViewController *)modalViewController;

@end
