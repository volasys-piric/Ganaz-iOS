//
//  GANWorkerJobListItemTVC.h
//  Ganaz
//
//  Created by Piric Djordje on 2/23/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GANWorkerJobListItemTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblCompany;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (strong, nonatomic) IBOutlet UILabel *lblUnit;
@property (strong, nonatomic) IBOutlet UILabel *lblPriceNA;

@end
