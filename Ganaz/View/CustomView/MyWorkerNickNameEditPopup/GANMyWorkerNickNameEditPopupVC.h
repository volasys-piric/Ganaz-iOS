//
//  GANMyWorkerNickNameEditPopupVC.h
//  Ganaz
//
//  Created by forever on 8/18/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GANMyWorkerNickNameEditPopupVCDelegate <NSObject>

@optional

- (void) nicknameEditPopupDidUpdateWithNickname: (NSString *) nickname;
- (void) nicknameEditPopupDidCancel;

@end

@interface GANMyWorkerNickNameEditPopupVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *textfieldNickname;

@property (nonatomic, weak) id<GANMyWorkerNickNameEditPopupVCDelegate> delegate;

- (void) setTitle:(NSString*) phoneNumber;

@end
