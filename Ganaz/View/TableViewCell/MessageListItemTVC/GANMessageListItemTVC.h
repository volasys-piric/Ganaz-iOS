//
//  GANMessageListItemTVC.h
//  Ganaz
//
//  Created by Chris Lin on 10/29/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GANUtils.h"

@interface GANMessageListItemTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelAvatar;
@property (weak, nonatomic) IBOutlet UILabel *labelDateTime;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelMessage;

- (void) refreshViewsWithType: (GANENUM_MESSAGE_TYPE) type DidRead: (BOOL) didRead DidSend: (BOOL) didSend;

@end
