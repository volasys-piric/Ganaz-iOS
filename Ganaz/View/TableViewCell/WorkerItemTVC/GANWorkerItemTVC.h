//
//  GANWorkerItemTVC.h
//  Ganaz
//
//  Created by Piric Djordje on 2/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GANWorkerItemTVCDelegate <NSObject>

- (void) setWorkerNickName : (NSInteger) nIndex;

@end

@interface GANWorkerItemTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblWorkerId;
@property (weak, nonatomic) IBOutlet UILabel *lblPoint;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;

@property (atomic, assign) NSInteger nIndex;
@property (weak, nonatomic) id<GANWorkerItemTVCDelegate> delegate;

- (void) setButtonColor:(BOOL) isWorker;
- (void) setItemSelected: (BOOL) selected;

@end
