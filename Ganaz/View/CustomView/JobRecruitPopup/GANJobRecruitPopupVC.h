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

- (void) didRecruitClick;
- (void) didViewCandidatesClick;
- (void) didEditJobClick;

@end

@interface GANJobRecruitPopupVC : UIViewController

@property (weak, nonatomic) id<GANJobRecruitPopupVCDelegate> delegate;

@end
