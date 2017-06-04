//
//  GANCompanyCodePopupVC.h
//  Ganaz
//
//  Created by Piric Djordje on 5/25/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GANCompanyCodePopupDelegate <NSObject>

- (void) didCompanyCodeVerify: (int) indexCompany;

@end

@interface GANCompanyCodePopupVC : UIViewController

@property (assign, atomic) int indexCompany;
@property (weak, nonatomic) id<GANCompanyCodePopupDelegate> delegate;

- (void) refreshFields;

@end
