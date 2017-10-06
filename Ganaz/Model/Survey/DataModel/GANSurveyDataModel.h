//
//  GANSurveyDataModel.h
//  Ganaz
//
//  Created by Chris Lin on 10/5/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANSurveyAnswerDataModel.h"
#import "GANUtils.h"

@interface GANSurveyDataModel : NSObject

@property (strong, nonatomic) NSString *szId;
@property (assign, atomic) GANENUM_SURVEYTYPE enumType;
@property (strong, nonatomic) GANUserRefDataModel *modelOwner;
@property (strong, nonatomic) GANTransContentsDataModel *modelQuestion;
@property (strong, nonatomic) NSMutableArray <GANTransContentsDataModel *> *arrayChoices;
@property (strong, nonatomic) NSMutableArray <GANUserRefDataModel *> *arrayReceivers;

@property (strong, nonatomic) NSMutableArray <GANSurveyAnswerDataModel *> *arrayAnswers;

@property (strong, nonatomic) NSDictionary *dictMetadata;
@property (assign, atomic) BOOL isAutoTranslate;
@property (strong, nonatomic) NSDate *dateSent;

- (instancetype) init;
- (void) setWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) serializeToDictionary;

#pragma mark - Utils

- (int) getCountForAnswersWithChoiceIndex: (int) indexChoice;

#pragma mark - Requests

- (void) requestGetAnswersWithCallback: (void (^) (int status)) callback;

@end
