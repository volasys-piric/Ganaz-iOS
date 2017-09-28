//
//  GANJobRecruitPopupVC.h
//  Ganaz
//
//  Created by forever on 8/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GANJobRecruitPopupVCDelegate <NSObject>

@optional

- (void) didRecruit;
- (void) didEdit;

@end

@interface GANJobRecruitPopupVC : UIViewController

@property (weak, nonatomic) id<GANJobRecruitPopupVCDelegate> delegate;

- (void) setDescriptionTitle:(NSString*)strDescription;
- (void) setRecruitButtonTitle:(NSString*)strTitle;
- (void) setEditButtonTitle:(NSString*)strTitle;

@end
