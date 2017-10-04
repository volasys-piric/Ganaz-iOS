//
//  GANSurveyTypeChoosePopupVC.h
//  Ganaz
//
//  Created by Chris Lin on 10/5/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GANSurveyTypeChoosePopupVC;

@protocol GANSurveyTypeChoosePopupDelegate <NSObject>

@optional

- (void) surveyTypeChoosePopupDidChoiceSingleClick: (GANSurveyTypeChoosePopupVC *) popup;
- (void) surveyTypeChoosePopupDidOpenTextClick: (GANSurveyTypeChoosePopupVC *) popup;
- (void) surveyTypeChoosePopupDidCancelClick: (GANSurveyTypeChoosePopupVC *) popup;

@end

@interface GANSurveyTypeChoosePopupVC : UIViewController

@property (weak, nonatomic) id<GANSurveyTypeChoosePopupDelegate> delegate;

@end
