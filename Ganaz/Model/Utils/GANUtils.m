//
//  GANUtils.m
//  Ganaz
//
//  Created by Piric Djordje on 3/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANUtils.h"
#import "GANGenericFunctionManager.h"
#import "GANUrlManager.h"
#import "GANNetworkRequestManager.h"
#import "Global.h"

@implementation GANUtils

// User Auth Type

+ (GANENUM_USER_AUTHTYPE) getUserAuthTypeFromString: (NSString *) szType{
    if ([szType caseInsensitiveCompare:@"phone"] == NSOrderedSame){
        return GANENUM_USER_AUTHTYPE_PHONE;
    }
    if ([szType caseInsensitiveCompare:@"email"] == NSOrderedSame){
        return GANENUM_USER_AUTHTYPE_EMAIL;
    }
    if ([szType caseInsensitiveCompare:@"facebook"] == NSOrderedSame){
        return GANENUM_USER_AUTHTYPE_FACEBOOK;
    }
    if ([szType caseInsensitiveCompare:@"twitter"] == NSOrderedSame){
        return GANENUM_USER_AUTHTYPE_TWITTER;
    }
    if ([szType caseInsensitiveCompare:@"google"] == NSOrderedSame){
        return GANENUM_USER_AUTHTYPE_GOOGLE;
    }
    return GANENUM_USER_AUTHTYPE_EMAIL;
}

+ (NSString *) getStringFromUserAuthType: (GANENUM_USER_AUTHTYPE) type{
    if (type == GANENUM_USER_AUTHTYPE_PHONE) return @"phone";
    if (type == GANENUM_USER_AUTHTYPE_EMAIL) return @"email";
    if (type == GANENUM_USER_AUTHTYPE_FACEBOOK) return @"facebook";
    if (type == GANENUM_USER_AUTHTYPE_TWITTER) return @"twitter";
    if (type == GANENUM_USER_AUTHTYPE_GOOGLE) return @"google";
    return @"phone";
}

// User Type

+ (GANENUM_USER_TYPE) getUserTypeFromString: (NSString *) szType{
    if ([szType caseInsensitiveCompare:@"worker"] == NSOrderedSame){
        return GANENUM_USER_TYPE_WORKER;
    }
    if([szType caseInsensitiveCompare:@"onboarding-worker"] == NSOrderedSame) {
        return GANENUM_USER_TYPE_ONBOARDING_WORKER;
    }
    if([szType caseInsensitiveCompare:@"facebook-lead-worker"] == NSOrderedSame) {
        return GANENUM_USER_TYPE_FACEBOOK_LEAD_WORKER;
    }
    
    if ([szType caseInsensitiveCompare:@"company-regular"] == NSOrderedSame){
        return GANENUM_USER_TYPE_COMPANY_REGULAR;
    }
    if ([szType caseInsensitiveCompare:@"company-admin"] == NSOrderedSame){
        return GANENUM_USER_TYPE_COMPANY_ADMIN;
    }
    return GANENUM_USER_TYPE_ANY;
}

+ (NSString *) getStringFromUserType: (GANENUM_USER_TYPE) type{
    if (type == GANENUM_USER_TYPE_WORKER) return @"worker";
    if (type == GANENUM_USER_TYPE_ONBOARDING_WORKER) return @"onboarding-worker";
    if (type == GANENUM_USER_TYPE_FACEBOOK_LEAD_WORKER) return @"facebook-lead-worker";
    
    if (type == GANENUM_USER_TYPE_COMPANY_REGULAR) return @"company-regular";
    if (type == GANENUM_USER_TYPE_COMPANY_ADMIN) return @"company-admin";
    return @"any";
}

// Pay Unit

+ (NSString *) getPayUnitFromString: (NSString *) szUnit{
    /*if ([szUnit caseInsensitiveCompare:@"hour"] == NSOrderedSame ||
        [szUnit caseInsensitiveCompare:@"hr"] == NSOrderedSame){
        return GANENUM_PAY_UNIT_HOUR;
    }
    if ([szUnit caseInsensitiveCompare:@"lb"] == NSOrderedSame){
        return GANENUM_PAY_UNIT_LB;
    }*/
    return szUnit;
}

// Field Condition Type

+ (GANENUM_FIELDCONDITION_TYPE) getFieldConditionTypeFromString: (NSString *) szType{
    if ([szType caseInsensitiveCompare:@"poor"] == NSOrderedSame) return GANENUM_FIELDCONDITION_TYPE_POOR;
    if ([szType caseInsensitiveCompare:@"average"] == NSOrderedSame) return GANENUM_FIELDCONDITION_TYPE_AVERAGE;
    if ([szType caseInsensitiveCompare:@"good"] == NSOrderedSame) return GANENUM_FIELDCONDITION_TYPE_GOOD;
    if ([szType caseInsensitiveCompare:@"excellent"] == NSOrderedSame) return GANENUM_FIELDCONDITION_TYPE_EXCELLENT;
    return GANENUM_FIELDCONDITION_TYPE_GOOD;
}

+ (NSString *) getStringFromFieldConditionType: (GANENUM_FIELDCONDITION_TYPE) type{
    if (type == GANENUM_FIELDCONDITION_TYPE_POOR) return @"poor";
    if (type == GANENUM_FIELDCONDITION_TYPE_AVERAGE) return @"average";
    if (type == GANENUM_FIELDCONDITION_TYPE_GOOD) return @"good";
    if (type == GANENUM_FIELDCONDITION_TYPE_EXCELLENT) return @"excellent";
    
    return @"good";
}

// Message Type

+ (GANENUM_MESSAGE_TYPE) getMessageTypeFromString: (NSString *) szType{
    if ([szType caseInsensitiveCompare:@"message"] == NSOrderedSame) return GANENUM_MESSAGE_TYPE_MESSAGE;
    if ([szType caseInsensitiveCompare:@"application"] == NSOrderedSame) return GANENUM_MESSAGE_TYPE_APPLICATION;
    if ([szType caseInsensitiveCompare:@"suggest"] == NSOrderedSame) return GANENUM_MESSAGE_TYPE_SUGGEST;
    if ([szType caseInsensitiveCompare:@"recruit"] == NSOrderedSame) return GANENUM_MESSAGE_TYPE_RECRUIT;
    if ([szType caseInsensitiveCompare:@"survey-choice-single"] == NSOrderedSame) return GANENUM_MESSAGE_TYPE_SURVEY_CHOICESINGLE;
    if ([szType caseInsensitiveCompare:@"survey-open-text"] == NSOrderedSame) return GANENUM_MESSAGE_TYPE_SURVEY_OPENTEXT;
    if ([szType caseInsensitiveCompare:@"survey-answer"] == NSOrderedSame) return GANENUM_MESSAGE_TYPE_SURVEY_ANSWER;
    if ([szType caseInsensitiveCompare:@"facebook-message"] == NSOrderedSame) return GANENUM_MESSAGE_TYPE_FACEBOOKMESSAGE;
    
    return GANENUM_MESSAGE_TYPE_MESSAGE;
}

+ (NSString *) getStringFromMessageType: (GANENUM_MESSAGE_TYPE) type{
    if (type == GANENUM_MESSAGE_TYPE_MESSAGE) return @"message";
    if (type == GANENUM_MESSAGE_TYPE_SUGGEST) return @"suggest";
    if (type == GANENUM_MESSAGE_TYPE_APPLICATION) return @"application";
    if (type == GANENUM_MESSAGE_TYPE_RECRUIT) return @"recruit";
    if (type == GANENUM_MESSAGE_TYPE_SURVEY_CHOICESINGLE) return @"survey-choice-single";
    if (type == GANENUM_MESSAGE_TYPE_SURVEY_OPENTEXT) return @"survey-open-text";
    if (type == GANENUM_MESSAGE_TYPE_SURVEY_ANSWER) return @"survey-answer";
    if (type == GANENUM_MESSAGE_TYPE_FACEBOOKMESSAGE) return @"facebook-message";
    
    return @"message";
}

// Message Read Status

+ (GANENUM_MESSAGE_STATUS) getMessageStatusFromString: (NSString *) szStatus{
    if ([szStatus caseInsensitiveCompare:@"new"] == NSOrderedSame) return GANENUM_MESSAGE_STATUS_NEW;
    if ([szStatus caseInsensitiveCompare:@"read"] == NSOrderedSame) return GANENUM_MESSAGE_STATUS_READ;
    return GANENUM_MESSAGE_STATUS_READ;
}

+ (NSString *) getStringFromMessageStatus: (GANENUM_MESSAGE_STATUS) status{
    if (status == GANENUM_MESSAGE_STATUS_NEW) return @"new";
    if (status == GANENUM_MESSAGE_STATUS_READ) return @"read";
    return @"read";
}

// Push Notification Type

+ (GANENUM_PUSHNOTIFICATION_TYPE) getPushNotificationTypeFromString: (NSString *) szType{
    if ([szType caseInsensitiveCompare:@"recruit"] == NSOrderedSame) return GANENUM_PUSHNOTIFICATION_TYPE_RECRUIT;
    if ([szType caseInsensitiveCompare:@"message"] == NSOrderedSame) return GANENUM_PUSHNOTIFICATION_TYPE_MESSAGE;
    if ([szType caseInsensitiveCompare:@"application"] == NSOrderedSame) return GANENUM_PUSHNOTIFICATION_TYPE_APPLICATION;
    if ([szType caseInsensitiveCompare:@"suggest"] == NSOrderedSame) return GANENUM_PUSHNOTIFICATION_TYPE_SUGGEST;
    return GANENUM_PUSHNOTIFICATION_TYPE_NONE;
}

+ (NSString *) getStringFromPushNotificationType: (GANENUM_PUSHNOTIFICATION_TYPE) type{
    if (type == GANENUM_PUSHNOTIFICATION_TYPE_RECRUIT) return @"recruit";
    if (type == GANENUM_PUSHNOTIFICATION_TYPE_MESSAGE) return @"message";
    if (type == GANENUM_PUSHNOTIFICATION_TYPE_APPLICATION) return @"application";
    if (type == GANENUM_PUSHNOTIFICATION_TYPE_SUGGEST) return @"suggest";
    return @"";
}

// Membership Plan Type

+ (GANENUM_MEMBERSHIPPLAN_TYPE) getMembershipPlayTypeFromString: (NSString *) szType{
    if ([szType caseInsensitiveCompare:@"free"] == NSOrderedSame) return GANENUM_MEMBERSHIPPLAN_TYPE_FREE;
    if ([szType caseInsensitiveCompare:@"premium"] == NSOrderedSame) return GANENUM_MEMBERSHIPPLAN_TYPE_PREMIUM;
    return GANENUM_MEMBERSHIPPLAN_TYPE_FREE;
}

+ (NSString *) getStringFromMembershipPlanType: (GANENUM_MEMBERSHIPPLAN_TYPE) type{
    if (type == GANENUM_MEMBERSHIPPLAN_TYPE_FREE) return @"free";
    if (type == GANENUM_MEMBERSHIPPLAN_TYPE_PREMIUM) return @"premium";
    return @"free";
}

// App Config

+ (GANENUM_APPCONFIG_ENV) getAppConfigEnvFromString: (NSString *) szEnv{
    if ([szEnv caseInsensitiveCompare:@"staging"] == NSOrderedSame) return GANENUM_APPCONFIG_ENV_STAGING;
    if ([szEnv caseInsensitiveCompare:@"demo"] == NSOrderedSame) return GANENUM_APPCONFIG_ENV_DEMO;
    if ([szEnv caseInsensitiveCompare:@"production"] == NSOrderedSame) return GANENUM_APPCONFIG_ENV_PRODUCTION;
    return GANENUM_APPCONFIG_ENV_DEMO;
}

+ (NSString *) getStringFromAppConfigEnv: (GANENUM_APPCONFIG_ENV) env{
    if (env == GANENUM_APPCONFIG_ENV_STAGING) return @"staging";
    if (env == GANENUM_APPCONFIG_ENV_DEMO) return @"demo";
    if (env == GANENUM_APPCONFIG_ENV_PRODUCTION) return @"production";
    return @"demo";
}

// Survey

+ (GANENUM_SURVEYTYPE) getSurveyTypeFromString: (NSString *) szType{
    if ([szType caseInsensitiveCompare:@"choice-single"] == NSOrderedSame) return GANENUM_SURVEYTYPE_CHOICESINGLE;
    if ([szType caseInsensitiveCompare:@"open-text"] == NSOrderedSame) return GANENUM_SURVEYTYPE_OPENTEXT;
    return GANENUM_SURVEYTYPE_CHOICESINGLE;
}

+ (NSString *) getStringFromSurveyType: (GANENUM_SURVEYTYPE) type{
    if (type == GANENUM_SURVEYTYPE_CHOICESINGLE) return @"choice-single";
    if (type == GANENUM_SURVEYTYPE_OPENTEXT) return @"open-text";
    return @"choice-single";
}

// Phone Country

+ (GANENUM_PHONE_COUNTRY) getCountryFromString: (NSString *) szCountry {
    if ([szCountry caseInsensitiveCompare:@"US"] == NSOrderedSame) return GANENUM_PHONE_COUNTRY_US;
    if ([szCountry caseInsensitiveCompare:@"MX"] == NSOrderedSame) return GANENUM_PHONE_COUNTRY_MX;
    return GANENUM_PHONE_COUNTRY_US;
}

+ (NSString *) getStringFromCountry: (GANENUM_PHONE_COUNTRY) country {
    if (country == GANENUM_PHONE_COUNTRY_US) return @"US";
    if (country == GANENUM_PHONE_COUNTRY_US) return @"MX";
    return @"US";
}

//


+ (GANENUM_APPCONFIG_SERVERSTATUS) getAppConfigServerStatusFromString: (NSString *) szStatus{
    if ([szStatus caseInsensitiveCompare:@"running"] == NSOrderedSame) return GANENUM_APPCONFIG_SERVERSTATUS_RUNNING;
    if ([szStatus caseInsensitiveCompare:@"maintenance"] == NSOrderedSame) return GANENUM_APPCONFIG_SERVERSTATUS_MAINTENANCE;
    if ([szStatus caseInsensitiveCompare:@"down"] == NSOrderedSame) return GANENUM_APPCONFIG_SERVERSTATUS_DOWN;
    return GANENUM_APPCONFIG_SERVERSTATUS_RUNNING;
}

+ (NSString *) getStringFromAppConfigServerStatus: (GANENUM_APPCONFIG_SERVERSTATUS) status{
    if (status == GANENUM_APPCONFIG_SERVERSTATUS_RUNNING) return @"running";
    if (status == GANENUM_APPCONFIG_SERVERSTATUS_MAINTENANCE) return @"maintenance";
    if (status == GANENUM_APPCONFIG_SERVERSTATUS_DOWN) return @"down";
    return @"running";
}

+ (void) syncImageWithUrl:(UIImageView *) imageView latitude:(float) latitude longitude:(float) longitude {
    NSString *szUrl = [GANUrlManager getEndpointForStaticMap:latitude longitue:longitude];
    
    CGSize size = CGSizeMake(imageView.frame.size.width, imageView.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    [[UIColor lightGrayColor] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *imagePlaceholder = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [imageView setImageWithURL:[NSURL URLWithString:szUrl] placeholderImage:imagePlaceholder];
}

// Translate

+ (void) requestTranslate: (NSString *) text
                Translate: (BOOL) shouldTranslate
             FromLanguage: (NSString *) fromLanguage
               ToLanguage: (NSString *) toLanguage
                 Callback: (void (^) (int status, NSString *translatedText)) callback{
    
    if (shouldTranslate == NO){
        if (callback) callback(SUCCESS_WITH_NO_ERROR, text);
        return;
    }
    
    NSString *szUrl = [GANUrlManager getEndpointForGoogleTranslate];
    NSDictionary *params = @{@"key": GOOGLE_TRANSLATE_API_KEY,
                             @"source": fromLanguage,
                             @"target": toLanguage,
                             @"q": text,
                             };
    
    [[GANNetworkRequestManager sharedInstance] GET:szUrl requireAuth:NO parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *arrTrans = [[responseObject objectForKey:@"data"] objectForKey:@"translations"];
        NSString *translatedText = [GANGenericFunctionManager refineNSString:[[arrTrans objectAtIndex:0] objectForKey:@"translatedText"]];
        if (callback) callback(SUCCESS_WITH_NO_ERROR, translatedText);
        
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(ERROR_UNKNOWN, @"");
    }];
}

+ (void) requestTranslateEsMultipleTexts: (NSArray <NSString *>*) texts
                               Translate: (BOOL) shouldTranslate
                                Callback:(void (^)(int, NSArray <GANTransContentsDataModel *> *))callback {
    NSMutableArray <GANTransContentsDataModel *> *arrayTransContents = [[NSMutableArray alloc] init];
    for (int i = 0; i < (int) [texts count]; i++) {
        NSString *text = [texts objectAtIndex:i];
        GANTransContentsDataModel *transContents = [[GANTransContentsDataModel alloc] init];
        transContents.szTextEN = text;
        transContents.szTextES = text;
        [arrayTransContents addObject:transContents];
    }
    
    if (shouldTranslate == NO) {
        if (callback) callback(SUCCESS_WITH_NO_ERROR, arrayTransContents);
        return;
    }
    
    NSString *szUrl = [GANUrlManager getEndpointForGoogleTranslate];
//    NSDictionary *params = @{@"key": GOOGLE_TRANSLATE_API_KEY,
//                             @"source": @"en",
//                             @"target": @"es",
//                             @"q": texts,
//                             };
    
    szUrl = [NSString stringWithFormat:@"%@?key=%@&source=en&target=es", szUrl, [GANGenericFunctionManager urlEncode:GOOGLE_TRANSLATE_API_KEY]];
    for (int i = 0; i < (int) [texts count]; i++) {
        szUrl = [NSString stringWithFormat:@"%@&q=%@", szUrl, [GANGenericFunctionManager urlEncode:[texts objectAtIndex:i]]];
    }
    
    [[GANNetworkRequestManager sharedInstance] GET:szUrl requireAuth:NO parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *arrTransTexts = [[responseObject objectForKey:@"data"] objectForKey:@"translations"];
        if ([arrTransTexts isKindOfClass:[NSArray class]] == YES && [arrTransTexts count] > 0) {
            for (int i = 0; i < [arrTransTexts count]; i++) {
                NSDictionary *dictTransText = [arrTransTexts objectAtIndex:i];
                GANTransContentsDataModel *transContents = [arrayTransContents objectAtIndex:i];
                transContents.szTextES = [GANGenericFunctionManager refineNSString:[dictTransText objectForKey:@"translatedText"]];
            }
        }
        if (callback) callback(SUCCESS_WITH_NO_ERROR, arrayTransContents);
        
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(ERROR_UNKNOWN, arrayTransContents);
    }];
}

@end
