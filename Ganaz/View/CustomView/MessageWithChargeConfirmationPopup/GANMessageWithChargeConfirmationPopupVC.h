//
//  GANMessageWithChargeConfirmationPopupVC.h
//  Ganaz
//
//  Created by Chris Lin on 10/6/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GANMessageWithChargeConfirmationPopupVC;

@protocol GANMessageWithChargeConfirmationPopupDelegate <NSObject>

@optional

- (void) messageWithChargeConfirmationPopupDidSendClick: (GANMessageWithChargeConfirmationPopupVC *) popup;
- (void) messageWithChargeConfirmationPopupDidCancelClick: (GANMessageWithChargeConfirmationPopupVC *) popup;

@end

@interface GANMessageWithChargeConfirmationPopupVC : UIViewController

@property (weak, nonatomic) id<GANMessageWithChargeConfirmationPopupDelegate> delegate;

- (void) setDescriptionWithCount: (NSInteger) count;

@end
