//
//  GANCompanySuggestWorkersItemTVC.h
//  Ganaz
//
//  Created by forever on 8/1/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GANCompanySuggestWorkersItemTVCDelegate <NSObject>

- (void) onWorkersShare:(NSInteger)nIndex;

@end

@interface GANCompanySuggestWorkersItemTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblPhoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;

@property (atomic, assign) NSInteger nIndex;
@property (weak, nonatomic) id<GANCompanySuggestWorkersItemTVCDelegate> delegate;

@end
