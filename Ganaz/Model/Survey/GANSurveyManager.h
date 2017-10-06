//
//  GANSurveyManager.h
//  Ganaz
//
//  Created by Chris Lin on 10/5/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANSurveyDataModel.h"

@interface GANSurveyManager : NSObject

@property (strong, nonatomic) NSMutableArray <GANSurveyDataModel *> *arraySurveys;
@property (assign, atomic) BOOL isLoading;

+ (instancetype) sharedInstance;
- (void) initializeManager;

#pragma mark - Requests

- (void) requestGetSurveyListWithCallback: (void (^) (int status)) callback;
- (void) requestCreateSurveyWithType: (GANENUM_SURVEYTYPE) type
                            Question: (NSString *) questionText
                             Choices: (NSArray <NSString *> *) choiceTexts
                           Receivers: (NSArray <GANUserRefDataModel *> *) receivers
                        PhoneNumbers: (NSArray <NSString *> *) phoneNumbers
                           MeataData: (NSDictionary *) metadata
                       AutoTranslate: (BOOL) isAutoTranslate
                            Callback: (void (^) (int status)) callback;

@end
