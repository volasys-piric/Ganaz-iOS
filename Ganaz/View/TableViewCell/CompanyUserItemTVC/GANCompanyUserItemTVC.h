//
//  GANCompanyUserItemTVC.h
//  Ganaz
//
//  Created by Piric Djordje on 6/2/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GANCompanyUserItemTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblCircle;

- (void) setItemSelected: (BOOL) selected;

@end
