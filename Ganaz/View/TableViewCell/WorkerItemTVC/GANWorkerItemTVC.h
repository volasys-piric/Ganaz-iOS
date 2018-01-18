//
//  GANWorkerItemTVC.h
//  Ganaz
//
//  Created by Piric Djordje on 2/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GANWorkerItemTVC;

@protocol GANWorkerItemTVCDelegate <NSObject>

@optional

- (void) workerItemTableViewCellDidDotsClick: (GANWorkerItemTVC *) cell;

@end

@interface GANWorkerItemTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblWorkerId;
@property (weak, nonatomic) IBOutlet UILabel *lblPoint;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;

@property (atomic, assign) int index;
@property (weak, nonatomic) id<GANWorkerItemTVCDelegate> delegate;

- (void) setButtonColor:(BOOL) isWorker;
- (void) setItemSelected: (BOOL) selected;

@end
