//
//  GANAppUpdatesPopupVC.h
//  Ganaz
//
//  Created by Piric Djordje on 7/4/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GANUtils.h"

@protocol GANAppUpdatesPopupDelegate <NSObject>

@optional

- (void) didUpdateClick;
- (void) didCancelClick;

@end

@interface GANAppUpdatesPopupVC : UIViewController

@property (weak, nonatomic) id<GANAppUpdatesPopupDelegate> delegate;

- (void) refreshFields;

@end
