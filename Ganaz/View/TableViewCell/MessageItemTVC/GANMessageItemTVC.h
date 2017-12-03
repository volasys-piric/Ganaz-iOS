//
//  GANMessageItemTVC.h
//  Ganaz
//
//  Created by forever on 9/8/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
#import "GANUtils.h"
#import "GANLocationManager.h"

@interface GANMessageItemTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblDateTime;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *lblMessage;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *imgMap;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintMapHeight;

@property (strong, nonatomic) CLLocation *locationCenter;

- (void) refreshViewsWithType: (GANENUM_MESSAGE_TYPE) type DidRead: (BOOL) didRead DidSend: (BOOL) didSend;

@end
