//
//  GANWorkerItemTVC.h
//  Ganaz
//
//  Created by Piric Djordje on 2/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GANWorkerItemTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblWorkerId;
@property (weak, nonatomic) IBOutlet UILabel *lblCircle;

- (void) setItemSelected: (BOOL) selected;

@end
