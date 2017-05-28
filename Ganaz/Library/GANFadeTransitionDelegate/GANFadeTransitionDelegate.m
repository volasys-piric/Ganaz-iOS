//
//  GANFadeTransitionDelegate.m
//  Ganaz
//
//  Created by Piric Djordje on 5/25/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANFadeTransitionDelegate.h"
#import "GANAnimatedTransitioning.h"

@implementation GANFadeTransitionDelegate

//===================================================================
// - UIViewControllerTransitioningDelegate
//===================================================================

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    GANAnimatedTransitioning *controller = [[GANAnimatedTransitioning alloc]init];
    controller.isPresenting = YES;
    return (id<UIViewControllerAnimatedTransitioning>)controller;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    //I will fix it later.
    //    AnimatedTransitioning *controller = [[AnimatedTransitioning alloc]init];
    //    controller.isPresenting = NO;
    //    return controller;
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

@end
