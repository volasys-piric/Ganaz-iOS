//
//  GANJobPostSuccessPopupVC.h
//  Ganaz
//
//  Created by forever on 7/31/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GANUtils.h"

@protocol GANJobPostSuccessPopupDelegate <NSObject>

@optional

- (void) didOK;

@end

@interface GANJobPostSuccessPopupVC : UIViewController

@property (weak, nonatomic) id<GANJobPostSuccessPopupDelegate> delegate;

- (void) refreshFields:(NSInteger) nCount;

@end
