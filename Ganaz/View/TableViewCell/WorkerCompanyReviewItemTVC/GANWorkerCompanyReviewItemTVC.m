//
//  GANWorkerCompanyReviewItemTVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/26/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANWorkerCompanyReviewItemTVC.h"

@implementation GANWorkerCompanyReviewItemTVC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) refreshViews{
    if (self.viewHCSRating == nil){
        self.viewHCSRating = [HCSStarRatingView new];
        self.viewHCSRating.emptyStarImage = [UIImage imageNamed:@"icon-star-unselected"];
        self.viewHCSRating.filledStarImage = [UIImage imageNamed:@"icon-star-selected"];
        self.viewHCSRating.allowsHalfStars = NO;
        self.viewHCSRating.frame = CGRectMake(0, 0, self.viewStarContainer.bounds.size.width, self.viewStarContainer.bounds.size.height);
        
        self.viewHCSRating.layer.backgroundColor = [UIColor clearColor].CGColor;
        self.viewHCSRating.backgroundColor = [UIColor clearColor];
        
        [self.viewStarContainer addSubview:self.viewHCSRating];
        
        [self.viewHCSRating addTarget:self action:@selector(didChangeValue:) forControlEvents:UIControlEventValueChanged];
    }
}

- (void) updateViewsWithIndex: (int) index Title: (NSString *) title Image: (NSString *) image Value: (int) value{
    self.index = index;
    self.value = value;
    
    self.viewContainer.layer.cornerRadius = 4;
    self.lblTitle.text = title;
    [self.imgIcon setImage:[UIImage imageNamed:image]];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self refreshViews];
    self.viewHCSRating.value = value;
}

- (IBAction)didChangeValue:(HCSStarRatingView *)sender {
    if (self.delegate){
        [self.delegate reviewItemCell:self Index:self.index onStarChanged:(int) sender.value];
    }
}

@end
