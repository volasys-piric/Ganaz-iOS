//
//  GANJobItemTVC.h
//  Ganaz
//
//  Created by Piric Djordje on 2/21/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GANJobItemTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblUnit;
@property (weak, nonatomic) IBOutlet UILabel *lblPriceNA;

- (void) showPayRate: (BOOL) show;
- (void) setItemSelected: (BOOL) selected;

@end
