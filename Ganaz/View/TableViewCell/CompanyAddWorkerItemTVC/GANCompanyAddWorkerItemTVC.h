//
//  GANCompanyAddWorkerItemTVC.h
//  Ganaz
//
//  Created by forever on 8/7/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GANCompanyAddWorkerItemTVC;

@protocol GANCompanyAddWorkerItemTVCDelegate <NSObject>

- (void) companyAddWorkerTableViewCellDidAddClick: (GANCompanyAddWorkerItemTVC *) cell;

@end

@interface GANCompanyAddWorkerItemTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelPhoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *buttonAdd;
@property (weak, nonatomic) IBOutlet UILabel *labelNameOnly;

@property (atomic, assign) int indexCell;
@property (weak, nonatomic) id<GANCompanyAddWorkerItemTVCDelegate> delegate;

@end
