//
//  GANConformMessagePopupVC.h
//  Ganaz
//
//  Created by forever on 9/12/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GANConformMessagePopupVCDelegate <NSObject>

@optional

- (void) didSendClick;
- (void) didCancelClick;

@end

@interface GANConformMessagePopupVC : UIViewController

@property (atomic, assign) NSInteger nIndex;
@property (nonatomic, weak) id<GANConformMessagePopupVCDelegate> delegate;

- (void) setDescription:(NSInteger) nCount;

@end
