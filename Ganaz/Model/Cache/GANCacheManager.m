//
//  GANCacheManager.m
//  Ganaz
//
//  Created by Piric Djordje on 5/28/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCacheManager.h"
#import "GANNetworkRequestManager.h"
#import "GANUrlManager.h"
#import "GANErrorManager.h"
#import "GANGenericFunctionManager.h"
#import "Global.h"

@implementation GANCacheManager

+ (instancetype) sharedInstance{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init{
    if (self = [super init]){
        [self initializeManager];
    }
    return self;
}

- (void) initializeManager{
    self.arrayCompanies = [[NSMutableArray alloc] init];
    self.arrayUsers = [[NSMutableArray alloc] init];
    self.arraySurvey = [[NSMutableArray alloc] init];
    self.arraySurveyAnswers = [[NSMutableArray alloc] init];
    [self initializeOnboardingAction];
}

#pragma mark - Onboarding Action

- (void) initializeOnboardingAction {
    self.modelOnboardingAction = [[GANOnboardingActionDataModel alloc] init];
}

#pragma mark Users

- (int) getIndexForUserWithUserId: (NSString *) userId{
    for (int i = 0; i < (int) [self.arrayUsers count]; i++){
        GANUserBaseDataModel *user = [self.arrayUsers objectAtIndex:i];
        if ([user.szId isEqualToString:userId]){
            return i;
        }
    }
    return -1;
}

- (int) addUserIfNeeded: (GANUserBaseDataModel *) userNew{
    for (int i = 0; i < (int) [self.arrayUsers count]; i++){
        GANUserBaseDataModel *user = [self.arrayUsers objectAtIndex:i];
        if ([user.szId isEqualToString:userNew.szId] == YES) return i;
    }
    [self.arrayUsers addObject:userNew];
    return (int) [self.arrayUsers count] - 1;
}

- (void) requestGetIndexForUserByUserId: (NSString *) userId Callback: (void (^) (int index)) callback{
    int index = [self getIndexForUserWithUserId:userId];
    if (index != -1){
        if (callback) callback(index);
        return;
    }
    
    [[GANUserManager sharedInstance] requestUserDetailsByUserId:userId Callback:^(int status, GANUserBaseDataModel *user) {
        if (status == SUCCESS_WITH_NO_ERROR){
            int index = [self addUserIfNeeded:user];
            if (callback) callback(index);
        }
        else {
            if (callback) callback(-1);
        }
    }];
}

#pragma mark - Company

- (int) addCompanyIfNeeded: (GANCompanyDataModel *) company{
    int index = [self getIndexForCompanyByCompanyId:company.szId];
    if (index != -1) return index;
    
    [self.arrayCompanies addObject:company];
    return (int) [self.arrayCompanies count] - 1;
}

- (int) getIndexForCompanyByCompanyId: (NSString *) companyId{
    for (int i = 0; i < (int) [self.arrayCompanies count]; i++){
        GANCompanyDataModel *company = [self.arrayCompanies objectAtIndex:i];
        if ([company.szId isEqualToString:companyId] == YES) return i;
    }
    return -1;
}

- (int) getIndexForCompanyByCompanyCode: (NSString *) companyCode{
    for (int i = 0; i < (int) [self.arrayCompanies count]; i++){
        GANCompanyDataModel *company = [self.arrayCompanies objectAtIndex:i];
        if ([company.szCode caseInsensitiveCompare:companyCode] == NSOrderedSame) return i;
    }
    return -1;
}
- (void) getCompanyBusinessNameESByCompanyId: (NSString *) companyId Callback: (void (^) (NSString *businessNameES)) callback{
    int index = [self getIndexForCompanyByCompanyId:companyId];
    if (index != -1){
        GANCompanyDataModel *company = [self.arrayCompanies objectAtIndex:index];
        if (callback) callback([company getBusinessNameES]);
        return;
    }
    else {
        [self requestGetCompanyDetailsByCompanyId:companyId Callback:^(int indexCompany) {
            if (indexCompany != -1){
                GANCompanyDataModel *company = [self.arrayCompanies objectAtIndex:indexCompany];
                if (callback) callback([company getBusinessNameES]);
            }
            else {
                if (callback) callback(@"Unknown");
            }
        }];
    }
}

- (void) requestGetCompanyDetailsByCompanyId: (NSString *) companyId Callback: (void (^) (int indexCompany)) callback{
    int index = [self getIndexForCompanyByCompanyId:companyId];
    if (index != -1){
        if (callback) callback(index);
        return;
    }
    else {
        NSString *szUrl = [GANUrlManager getEndpointForGetCompanyDetailsByCompanyId:companyId];
        [[GANNetworkRequestManager sharedInstance] GET:szUrl requireAuth:NO parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *dict = responseObject;
            BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
            if (success){
                GANCompanyDataModel *company = [[GANCompanyDataModel alloc] init];
                NSDictionary *dictCompany = [dict objectForKey:@"company"];
                [company setWithDictionary:dictCompany];
                int indexCompany = [self addCompanyIfNeeded:company];
                
                if (callback) callback(indexCompany);
            }
            else {
                if (callback) callback(-1);
            }
        } failure:^(int status, NSDictionary *error) {
            if (callback) callback(-1);
        }];
    }
}

- (void) requestGetCompanyDetailsByCompanyCode: (NSString *) companyCode Callback: (void (^) (int indexCompany)) callback{
    int index = [self getIndexForCompanyByCompanyCode:companyCode];
    if (index != -1){
        if (callback) callback(index);
        return;
    }
    else {
        NSString *szUrl = [GANUrlManager getEndpointForSearchCompany];
        NSDictionary *param = @{@"code": companyCode};
        
        [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:NO parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *dict = responseObject;
            BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
            if (success){
                NSArray *arr = [dict objectForKey:@"companies"];
                for (int i = 0; i < (int) [arr count]; i++){
                    NSDictionary *dictCompany = [arr objectAtIndex:i];
                    GANCompanyDataModel *company = [[GANCompanyDataModel alloc] init];
                    [company setWithDictionary:dictCompany];
                    [self addCompanyIfNeeded:company];
                }
                int indexCompany = [self getIndexForCompanyByCompanyCode:companyCode];
                if (callback) callback(indexCompany);
            }
            else {
                if (callback) callback(-1);
            }
        } failure:^(int status, NSDictionary *error) {
            if (callback) callback(-1);
        }];
    }
}

- (GANCompanyDataModel *) getCompanyByJobId: (NSString *) jobId{
    for (int i = 0; i < (int) [self.arrayCompanies count]; i++){
        GANCompanyDataModel *company = [self.arrayCompanies objectAtIndex:i];
        int indexJob = [company getIndexForJob:jobId];
        if (indexJob != -1){
            return company;
        }
    }
    return nil;
}

#pragma mark - Job

- (GANJobDataModel *) getJobByJobId: (NSString *) jobId{
    for (int i = 0; i < (int) [self.arrayCompanies count]; i++){
        GANCompanyDataModel *company = [self.arrayCompanies objectAtIndex:i];
        int indexJob = [company getIndexForJob:jobId];
        if (indexJob != -1){
            return [company.arrJobs objectAtIndex:indexJob];
        }
    }
    return nil;
}

#pragma mark - Survey

- (int) getIndexForSurveyWithSurveyId: (NSString *) surveyId{
    for (int i = 0; i < (int) [self.arraySurvey count]; i++){
        GANSurveyDataModel *survey = [self.arraySurvey objectAtIndex:i];
        if ([survey.szId isEqualToString:surveyId]){
            return i;
        }
    }
    return -1;
}

- (int) addSurveyIfNeeded: (GANSurveyDataModel *) surveyNew{
    for (int i = 0; i < (int) [self.arraySurvey count]; i++){
        GANSurveyDataModel *survey = [self.arraySurvey objectAtIndex:i];
        if ([survey.szId isEqualToString:surveyNew.szId] == YES) return i;
    }
    [self.arraySurvey addObject:surveyNew];
    return (int) [self.arraySurvey count] - 1;
}

- (void) requestGetIndexForSurveyBySurveyId: (NSString *) surveyId Callback: (void (^) (int index)) callback{
    int index = [self getIndexForSurveyWithSurveyId:surveyId];
    if (index != -1){
        if (callback) callback(index);
        return;
    }
    
    [[GANSurveyManager sharedInstance] requestSurveyDetailsBySurveyId:surveyId Callback:^(int status, GANSurveyDataModel *survey) {
        if (survey != nil) {
            int index = [self addSurveyIfNeeded:survey];
            if (callback) callback(index);
        }
        else {
            if (callback) callback(-1);
        }
    }];
}

#pragma mark - Survey Answers

- (int) getIndexForSurveyAnswerWithAnswerId: (NSString *) answerId{
    for (int i = 0; i < (int) [self.arraySurveyAnswers count]; i++){
        GANSurveyAnswerDataModel *answer = [self.arraySurveyAnswers objectAtIndex:i];
        if ([answer.szId isEqualToString:answerId]){
            return i;
        }
    }
    return -1;
}

- (int) addSurveyAnswerIfNeeded: (GANSurveyAnswerDataModel *) answerNew{
    for (int i = 0; i < (int) [self.arraySurveyAnswers count]; i++){
        GANSurveyAnswerDataModel *answer = [self.arraySurveyAnswers objectAtIndex:i];
        if ([answer.szId isEqualToString:answerNew.szId] == YES) return i;
    }
    [self.arraySurveyAnswers addObject:answerNew];
    return (int) [self.arraySurveyAnswers count] - 1;
}

- (void) requestGetIndexForSurveyAnswerByAnswerId: (NSString *) answerId Callback: (void (^) (int index)) callback{
    int index = [self getIndexForSurveyAnswerWithAnswerId:answerId];
    if (index != -1){
        if (callback) callback(index);
        return;
    }
    
    [[GANSurveyManager sharedInstance] requestSurveyAnswerDetailsByAnswerId:answerId Callback:^(int status, GANSurveyAnswerDataModel *answer) {
        if (answer != nil) {
            int index = [self addSurveyAnswerIfNeeded:answer];
            if (callback) callback(index);
        }
        else {
            if (callback) callback(-1);
        }
    }];
}

- (int) getIndexForSurveyAnswerWithSurveyId: (NSString *) surveyId ResponderUserId: (NSString *) userId{
    for (int i = 0; i < (int) [self.arraySurveyAnswers count]; i++) {
        GANSurveyAnswerDataModel *answer = [self.arraySurveyAnswers objectAtIndex:i];
        if ([answer.szSurveyId isEqualToString:surveyId] == YES &&
            [answer.modelResponder.szUserId isEqualToString:userId] == YES) {
            return i;
        }
    }
    return -1;
}

@end
