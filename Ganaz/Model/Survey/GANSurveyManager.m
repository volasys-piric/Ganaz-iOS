//
//  GANSurveyManager.m
//  Ganaz
//
//  Created by Chris Lin on 10/5/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANSurveyManager.h"
#import "GANUserManager.h"
#import "GANNetworkRequestManager.h"
#import "GANUrlManager.h"
#import "GANGenericFunctionManager.h"
#import "GANErrorManager.h"
#import "Global.h"

@implementation GANSurveyManager

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
    self.arraySurveys = [[NSMutableArray alloc] init];
    self.isLoading = NO;
}

#pragma mark - Utils

- (BOOL) addSurveyIfNeeded: (GANSurveyDataModel *) newSurvey{
    if (newSurvey == nil) return NO;
    for (int i = 0; i < (int) [self.arraySurveys count]; i++){
        GANSurveyDataModel *survey = [self.arraySurveys objectAtIndex:i];
        if ([survey.szId isEqualToString:newSurvey.szId] == YES) return NO;
    }
    [self.arraySurveys addObject:newSurvey];
    return YES;
}

- (int) getIndexForSurveyWithSurveyId: (NSString *) surveyId{
    for (int i = 0; i < (int) [self.arraySurveys count]; i++){
        GANSurveyDataModel *survey = [self.arraySurveys objectAtIndex:i];
        if ([survey.szId isEqualToString:surveyId] == YES){
            return i;
        }
    }
    return -1;
}

#pragma mark - Requests

- (void) requestGetSurveyListWithCallback: (void (^) (int status)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForGetSurveys];
    NSDictionary *param = @{@"owner": @{@"company_id": [GANUserManager getCompanyDataModel].szId}};
    
    self.isLoading = YES;
    
    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:YES parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        self.isLoading = NO;
        
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSArray *arraySurveys = [dict objectForKey:@"surveys"];
            [self.arraySurveys removeAllObjects];
            
            for (int i = 0; i < (int) [arraySurveys count]; i++){
                NSDictionary *dictSurvey = [arraySurveys objectAtIndex:i];
                GANSurveyDataModel *survey = [[GANSurveyDataModel alloc] init];
                [survey setWithDictionary:dictSurvey];
                [self.arraySurveys addObject:survey];
            }
            
            if (callback) callback(SUCCESS_WITH_NO_ERROR);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_SURVEYLIST_UPDATED object:nil];
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_SURVEYLIST_UPDATEFAILED object:nil];
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_SURVEYLIST_UPDATEFAILED object:nil];
    }];
}

- (void) requestCreateSurveyWithType: (GANENUM_SURVEYTYPE) type
                            Question: (NSString *) questionText
                             Choices: (NSArray <NSString *> *) choiceTexts
                           Receivers: (NSArray <GANUserRefDataModel *> *) receivers
                        PhoneNumbers: (NSArray <NSString *> *) phoneNumbers
                           MeataData: (NSDictionary *) metadata
                       AutoTranslate: (BOOL) isAutoTranslate
                            Callback: (void (^) (int status)) callback{
    
    NSMutableArray *arrayTexts = [[NSMutableArray alloc] init];
    [arrayTexts addObject:questionText];
    if (choiceTexts != nil) {
        [arrayTexts addObjectsFromArray:choiceTexts];
    }
    
    [GANUtils requestTranslateEsMultipleTexts:arrayTexts Translate:isAutoTranslate Callback:^(int status, NSArray<GANTransContentsDataModel *> *arrayTransContents) {
        GANTransContentsDataModel *question = [arrayTransContents objectAtIndex:0];
        NSMutableArray <GANTransContentsDataModel *> *choices = [[NSMutableArray alloc] init];
        for (int i = 1; i < (int) [arrayTransContents count]; i++){
            [choices addObject:[arrayTransContents objectAtIndex:i]];
        }
       
        NSString *szUrl = [GANUrlManager getEndpointForCreateSurvey];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        
        [params setObject:[GANUtils getStringFromSurveyType:type] forKey:@"type"];
        [params setObject:@{@"company_id": [GANUserManager getCompanyDataModel].szId,
                            @"user_id": [GANUserManager getUserCompanyDataModel].szId,
                            } forKey:@"owner"];
        [params setObject:[question serializeToDictionary] forKey:@"question"];
        
        NSMutableArray *arrayChoicesDictionary = [[NSMutableArray alloc] init];
        for (int i = 0; i < (int) [choices count]; i++){
            [arrayChoicesDictionary addObject:[[choices objectAtIndex:i] serializeToDictionary]];
        }
        [params setObject:arrayChoicesDictionary forKey:@"choices"];
        
        NSMutableArray *arrayReceiversDictionary = [[NSMutableArray alloc] init];
        for (int i = 0; i < (int) [receivers count]; i++){
            [arrayReceiversDictionary addObject:[[receivers objectAtIndex:i] serializeToDictionary]];
        }
        [params setObject:arrayReceiversDictionary forKey:@"receivers"];
        
        if([phoneNumbers count] > 0) {
            [params setObject:phoneNumbers forKey:@"receivers_phone_numbers"];
        }
        
        if(metadata != nil) {
            [params setObject:metadata forKey:@"metadata"];
        }
        
        [params setObject:(isAutoTranslate == YES) ? @"true" : @"false" forKey:@"auto_translate"];
        
        [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:YES parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *dict = responseObject;
            BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
            if (success){
                NSDictionary *dictSurvey = [dict objectForKey:@"survey"];
                GANSurveyDataModel *survey = [[GANSurveyDataModel alloc] init];
                [survey setWithDictionary:dictSurvey];
                [self addSurveyIfNeeded:survey];
                if (callback) callback(SUCCESS_WITH_NO_ERROR);
            }
            else {
                NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
                if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
            }
        } failure:^(int status, NSDictionary *error) {
            if (callback) callback(status);
        }];

    }];
}

@end
