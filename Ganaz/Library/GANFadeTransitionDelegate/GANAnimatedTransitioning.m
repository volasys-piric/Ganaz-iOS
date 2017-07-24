//
//  GANAnimatedTransitioning.m
//  Ganaz
//
//  Created by Piric Djordje on 5/25/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANAnimatedTransitioning.h"

#define TRANSITION_FADEOUT_DURATION                 0.25

@implementation GANAnimatedTransitioning

//===================================================================
// - UIViewControllerAnimatedTransitioning
//===================================================================

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return TRANSITION_FADEOUT_DURATION;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *inView = [transitionContext containerView];
    UIViewController *toVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [inView addSubview:toVC.view];
    
    [toVC.view setFrame:CGRectMake(0, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
    toVC.view.alpha = 0;
    
    [UIView animateWithDuration:TRANSITION_FADEOUT_DURATION
                     animations:^{
                         toVC.view.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                     }];
}

@end
