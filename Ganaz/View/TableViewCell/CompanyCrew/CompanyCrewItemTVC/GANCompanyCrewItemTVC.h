//
//  GANCompanyCrewItemTVC.h
//  Ganaz
//
//  Created by Chris Lin on 11/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GANCompanyCrewItemTVC;

@protocol GANCompanyCrewItemTVCDelegate <NSObject>

@optional

- (void) companyCrewItemCellDidDotClick: (GANCompanyCrewItemTVC *) cell;

@end

@interface GANCompanyCrewItemTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewContainer;

@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelDots;
@property (weak, nonatomic) IBOutlet UIButton *buttonDots;

@property (assign, atomic) int index;
@property (assign, atomic) BOOL isSelected;
@property (weak, nonatomic) id<GANCompanyCrewItemTVCDelegate> delegate;

- (void) setItemSelected: (BOOL) selected;

@end
