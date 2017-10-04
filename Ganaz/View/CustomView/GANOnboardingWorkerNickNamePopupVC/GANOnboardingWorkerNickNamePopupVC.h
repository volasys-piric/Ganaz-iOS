//
//  GANOnboardingWorkerNickNamePopupVC.h
//  Ganaz
//
//  Created by forever on 9/17/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GANOnboardingWorkerNickNamePopupVCDelegate <NSObject>

- (void) setOnboardingWorkerNickName:(NSString*)szNickName index:(NSInteger) nIndex;

@end

@interface GANOnboardingWorkerNickNamePopupVC : UIViewController

@property (atomic, assign) NSInteger nIndex;
@property (weak, nonatomic) IBOutlet UITextField *txtNickName;
@property (nonatomic, weak) id<GANOnboardingWorkerNickNamePopupVCDelegate> delegate;

- (void) setTitle:(NSString*) phoneNumber;

@end
