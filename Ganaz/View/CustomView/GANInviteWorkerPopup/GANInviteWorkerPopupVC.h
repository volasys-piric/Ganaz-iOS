//
//  GANInviteWorkerPopupVC.h
//  Ganaz
//
//  Created by forever on 9/17/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GANInviteWorkerPopupVC;

@protocol GANInviteWorkerPopupVCDelegate <NSObject>

@optional

- (void) companyInviteWorkerPopupDidInviteWorker: (GANInviteWorkerPopupVC *) popup;
- (void) companyInviteWorkerPopupDidCommunicateWithWorker: (GANInviteWorkerPopupVC *) popup;
- (void) companyInviteWorkerPopupDidCancel: (GANInviteWorkerPopupVC *) popup;

@end

@interface GANInviteWorkerPopupVC : UIViewController

@property (nonatomic, weak) id<GANInviteWorkerPopupVCDelegate> delegate;

- (void) setDescription:(NSString *) szName;

@end
