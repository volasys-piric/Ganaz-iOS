//
//  GANCacheManager.h
//  Ganaz
//
//  Created by Piric Djordje on 5/28/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANUserManager.h"
#import "GANJobDataModel.h"
#import "GANCompanyDataModel.h"
#import "GANSurveyManager.h"
#import "GANOnboardingActionDataModel.h"

@interface GANCacheManager : NSObject

@property (strong, nonatomic) NSMutableArray <GANUserBaseDataModel *> *arrayUsers;
@property (strong, nonatomic) NSMutableArray <GANCompanyDataModel *> *arrayCompanies;
@property (strong, nonatomic) NSMutableArray <GANSurveyDataModel *> *arraySurvey;
@property (strong, nonatomic) NSMutableArray <GANSurveyAnswerDataModel *> *arraySurveyAnswers;

@property (strong, nonatomic) GANOnboardingActionDataModel *modelOnboardingAction;

+ (instancetype) sharedInstance;
- (void) initializeManager;

#pragma mark - Onboarding Action

- (void) initializeOnboardingAction;

#pragma mark Users

- (int) getIndexForUserWithUserId: (NSString *) userId;
- (int) addUserIfNeeded: (GANUserBaseDataModel *) userNew;
- (void) requestGetIndexForUserByUserId: (NSString *) userId Callback: (void (^) (int index)) callback;

#pragma mark - Company

- (int) addCompanyIfNeeded: (GANCompanyDataModel *) company;
- (int) getIndexForCompanyByCompanyId: (NSString *) companyId;
- (int) getIndexForCompanyByCompanyCode: (NSString *) companyCode;
- (void) getCompanyBusinessNameESByCompanyId: (NSString *) companyId Callback: (void (^) (NSString *businessNameES)) callback;
- (void) requestGetCompanyDetailsByCompanyId: (NSString *) companyId Callback: (void (^) (int indexCompany)) callback;
- (void) requestGetCompanyDetailsByCompanyCode: (NSString *) companyCode Callback: (void (^) (int indexCompany)) callback;
- (GANCompanyDataModel *) getCompanyByJobId: (NSString *) jobId;

#pragma mark - Job

- (GANJobDataModel *) getJobByJobId: (NSString *) jobId;

#pragma mark - Survey

- (int) getIndexForSurveyWithSurveyId: (NSString *) surveyId;
- (int) addSurveyIfNeeded: (GANSurveyDataModel *) surveyNew;
- (void) requestGetIndexForSurveyBySurveyId: (NSString *) surveyId Callback: (void (^) (int index)) callback;

#pragma mark - Survey Answers

- (int) getIndexForSurveyAnswerWithAnswerId: (NSString *) answerId;
- (int) addSurveyAnswerIfNeeded: (GANSurveyAnswerDataModel *) answerNew;
- (void) requestGetIndexForSurveyAnswerByAnswerId: (NSString *) answerId Callback: (void (^) (int index)) callback;
- (int) getIndexForSurveyAnswerWithSurveyId: (NSString *) surveyId ResponderUserId: (NSString *) userId;

@end
