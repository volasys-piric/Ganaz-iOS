//
//  GANMyWorkerNickNameEditPopupVC.h
//  Ganaz
//
//  Created by forever on 8/18/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GANMyWorkerNickNameEditPopupVCDelegate <NSObject>

- (void) setMyWorkerNickName:(NSString*)szNickName index:(NSInteger) nIndex;

@end

@interface GANMyWorkerNickNameEditPopupVC : UIViewController
@property (atomic, assign) NSInteger nIndex;
@property (weak, nonatomic) IBOutlet UITextField *txtNickName;
@property (nonatomic, strong) id<GANMyWorkerNickNameEditPopupVCDelegate> delegate;

- (void) setTitle:(NSString*) phoneNumber;

@end
