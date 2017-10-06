//
//  GANSurveyChoiceSingleResultLegendItemTVC.h
//  Ganaz
//
//  Created by Chris Lin on 10/7/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GANSurveyChoiceSingleResultLegendItemTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelDot;
@property (weak, nonatomic) IBOutlet UILabel *labelAnswer;

- (void) refreshViewsWithFillColor: (UIColor *) colorFill BorderColor: (UIColor *) colorBorder Text: (NSString *) text;

@end
