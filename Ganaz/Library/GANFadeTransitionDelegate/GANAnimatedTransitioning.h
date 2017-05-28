//
//  GANAnimatedTransitioning.h
//  Ganaz
//
//  Created by Piric Djordje on 5/25/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GANAnimatedTransitioning : NSObject <UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) BOOL isPresenting;

@end
