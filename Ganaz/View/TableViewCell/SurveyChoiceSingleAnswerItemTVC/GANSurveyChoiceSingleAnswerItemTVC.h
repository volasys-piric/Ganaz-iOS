//
//  GANSurveyChoiceSingleAnswerItemTVC.h
//  Ganaz
//
//  Created by Chris Lin on 10/7/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GANSurveyChoiceSingleAnswerItemTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UILabel *labelAnswer;
@property (weak, nonatomic) IBOutlet UIImageView *imageCheck;

@property (assign, atomic) BOOL isSelected;

- (void) refreshViews;

@end
