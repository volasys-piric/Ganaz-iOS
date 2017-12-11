//
//  GANCompanyCrewWorkerItemTVC.h
//  Ganaz
//
//  Created by Chris Lin on 11/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GANCompanyCrewWorkerItemTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UILabel *labelName;

@property (assign, atomic) int index;
@property (assign, atomic) BOOL isSelected;

- (void) setItemSelected: (BOOL) selected;

@end
