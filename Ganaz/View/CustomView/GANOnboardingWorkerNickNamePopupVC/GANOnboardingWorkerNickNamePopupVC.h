//
//  GANOnboardingWorkerNickNamePopupVC.h
//  Ganaz
//
//  Created by forever on 9/17/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GANOnboardingWorkerNickNamePopupVCDelegate <NSObject>

@optional

- (void) onboardingNicknameEditPopupDidUpdateWithNickname: (NSString *) nickname;
- (void) onboardingNicknameEditPopupDidCancel;

@end

@interface GANOnboardingWorkerNickNamePopupVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *textfieldNickname;

@property (nonatomic, weak) id<GANOnboardingWorkerNickNamePopupVCDelegate> delegate;

- (void) setTitle:(NSString*) phoneNumber;

@end
