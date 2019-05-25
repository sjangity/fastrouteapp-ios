//
//  BlurViewController.m
//  SpringAndBlurDemo
//
//  Created by Sergio Campamá on 1/18/14.
//  Copyright (c) 2014 Sergio Campamá. All rights reserved.
//

#import "BlurViewController.h"

@interface BlurViewController ()

@property (nonatomic, strong) UINavigationBar *lenderBar;

@end

@implementation BlurViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.lenderBar = [[UINavigationBar alloc] initWithFrame:self.view.bounds];
    self.lenderBar.barStyle = UIBarStyleDefault;
    [self.view.layer insertSublayer:self.lenderBar.layer atIndex:0];
    
    UIInterpolatingMotionEffect *centerX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    centerX.maximumRelativeValue = @20;
    centerX.minimumRelativeValue = @-20;
    
    UIInterpolatingMotionEffect *centerY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    centerY.maximumRelativeValue = @20;
    centerY.minimumRelativeValue = @-20;
    
    UIMotionEffectGroup *effectGroup = [UIMotionEffectGroup new];
    effectGroup.motionEffects = @[centerX, centerY];
    [self.view addMotionEffect:effectGroup];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    //Hackity hack?
    self.lenderBar.frame = self.view.bounds;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.view setNeedsUpdateConstraints];
}

@end
