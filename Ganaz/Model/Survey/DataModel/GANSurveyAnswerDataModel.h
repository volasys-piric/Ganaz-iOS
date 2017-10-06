//
//  GANSurveyAnswerDataModel.h
//  Ganaz
//
//  Created by Chris Lin on 10/5/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANUtils.h"

@interface GANSurveyAnswerDataModel : NSObject

@property (strong, nonatomic) NSString *szId;
@property (strong, nonatomic) NSString *szSurveyId;
@property (assign, atomic) int indexChoice;
@property (strong, nonatomic) GANTransContentsDataModel *modelAnswerText;
@property (strong, nonatomic) GANUserRefDataModel *modelResponder;

@property (strong, nonatomic) NSDictionary *dictMetadata;
@property (assign, atomic) BOOL isAutoTranslate;
@property (strong, nonatomic) NSDate *dateSent;

- (instancetype) init;
- (void) setWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) serializeToDictionary;

@end
