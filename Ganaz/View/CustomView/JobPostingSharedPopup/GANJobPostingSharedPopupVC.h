//
//  GANJobPostingSharedPopupVC.h
//  Ganaz
//
//  Created by forever on 8/1/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GANJobPostingSharedPopupVCDelegate <NSObject>

@optional

- (void) didOK;

@end

@interface GANJobPostingSharedPopupVC : UIViewController

@property (weak, nonatomic) id<GANJobPostingSharedPopupVCDelegate> delegate;

- (void) refreshFields:(NSString*) strDescription;
@end
