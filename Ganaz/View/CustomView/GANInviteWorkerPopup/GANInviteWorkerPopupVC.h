//
//  GANInviteWorkerPopupVC.h
//  Ganaz
//
//  Created by forever on 9/17/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GANInviteWorkerPopupVCDelegate <NSObject>

- (void) InviteWorkertoGanaz;
- (void) CommunicateWithWorkers;

@end

@interface GANInviteWorkerPopupVC : UIViewController

@property (atomic, assign) NSInteger nIndex;
@property (nonatomic, weak) id<GANInviteWorkerPopupVCDelegate> delegate;

- (void) setDescription:(NSString *) szName;


@end
