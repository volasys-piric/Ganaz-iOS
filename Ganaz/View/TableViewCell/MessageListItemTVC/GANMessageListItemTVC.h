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

/*
 This "index" is mainly used in Worker > MessageListVC, where cell contents are updated by async call to server (to get company details, job details, etc).
 When updating in the return of async call, the celll might have been already initiated for another message item, which means, it might overwrite with old data.
 
 Please check GANWorkerMessageListVC.m > configureCell methods...
 This happens same in Company section.
 */
@property (assign, atomic) int index;

- (void) refreshViewsWithType: (GANENUM_MESSAGE_TYPE) type DidRead: (BOOL) didRead DidSend: (BOOL) didSend;

@end
