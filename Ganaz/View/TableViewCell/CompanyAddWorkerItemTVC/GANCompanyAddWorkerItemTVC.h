//
//  GANCompanyAddWorkerItemTVC.h
//  Ganaz
//
//  Created by forever on 8/7/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GANCompanyAddWorkerItemTVCDelegate <NSObject>

- (void) onAddWorker:(NSInteger)nIndex;

@end

@interface GANCompanyAddWorkerItemTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblPhoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;

@property (atomic, assign) NSInteger nIndex;
@property (weak, nonatomic) id<GANCompanyAddWorkerItemTVCDelegate> delegate;

@end
