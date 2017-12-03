//
//  GANWorkerCompanyReviewItemTVC.h
//  Ganaz
//
//  Created by Piric Djordje on 2/26/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCSStarRatingView.h"

@class GANWorkerCompanyReviewItemTVC;

@protocol GANWorkerCompanyReviewItemCellDelegate <NSObject>

- (void) reviewItemCell: (GANWorkerCompanyReviewItemTVC *) cell Index: (int) indexCell onStarChanged: (int) star;

@end

@interface GANWorkerCompanyReviewItemTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;

@property (weak, nonatomic) IBOutlet UIView *viewStarContainer;
@property (strong, nonatomic) IBOutlet HCSStarRatingView *viewHCSRating;

@property (assign, atomic) int index;
@property (assign, atomic) int value;

@property (weak, nonatomic) id<GANWorkerCompanyReviewItemCellDelegate> delegate;

- (void) updateViewsWithIndex: (int) index Title: (NSString *) title Image: (NSString *) image Value: (int) value;

@end
