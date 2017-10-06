//
//  GANUrlManager.m
//  Ganaz
//
//  Created by Piric Djordje on 2/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANUrlManager.h"
#import "Global.h"
#import "GANAppManager.h"
#import "GANGenericFunctionManager.h"

@implementation GANUrlManager

#pragma mark - Endpoint for AppSettings

+ (NSString *) getEndpointForAppConfig{
    return [NSString stringWithFormat:@"%@/config.json?token=%@", GANURL_GATEWAY, [GANGenericFunctionManager generateRandomString:8]];
}

+ (NSString *) getBaseUrl{
    return [NSString stringWithFormat:@"%@/api/v1", [GANAppManager sharedInstance].config.szBaseUrl];
}

#pragma mark - Endpoint for Location

+ (NSString *) getEndpointForGooglemapsGeocode{
    return @"http://maps.googleapis.com/maps/api/geocode/json";
}

+ (NSString *) getEndpointForGooglemapsPlaceAutoComplete{
    return @"https://maps.googleapis.com/maps/api/place/autocomplete/json";
}

+ (NSString *) getEndpointForGooglemapsPlaceDetails{
    return @"https://maps.googleapis.com/maps/api/place/details/json";
}

+ (NSString *) getEndpointForGooglemapsDirections{
    return @"https://maps.googleapis.com/maps/api/directions/json";
}

#pragma mark - Endpoint for Company

+ (NSString *) getEndpointForCreateCompany{
    return [NSString stringWithFormat:@"%@/company", [GANUrlManager getBaseUrl]];
}

+ (NSString *) getEndpointForGetCompanyDetailsByCompanyId: (NSString *) companyId{
    return [NSString stringWithFormat:@"%@/company/%@", [GANUrlManager getBaseUrl], companyId];
}

+ (NSString *) getEndpointForSearchCompany{
    return [NSString stringWithFormat:@"%@/company/search", [GANUrlManager getBaseUrl]];
}

#pragma mark - Endpoint for User
+ (NSString *) getEndpointForOnboardingUserSignup:(NSString *)szUserId{
    return [NSString stringWithFormat:@"%@/user/onboarding/%@", [GANUrlManager getBaseUrl], szUserId];
}

+ (NSString *) getEndpointForUserSignup{
    return [NSString stringWithFormat:@"%@/user", [GANUrlManager getBaseUrl]];
}

+ (NSString *) getEndpointForUserLogin{
    return [NSString stringWithFormat:@"%@/user/login", [GANUrlManager getBaseUrl]];
}

+ (NSString *) getEndpointForUserUpdateProfile{
    return [NSString stringWithFormat:@"%@/user", [GANUrlManager getBaseUrl]];
}

+ (NSString *) getEndpointForUserSearch{
    return [NSString stringWithFormat:@"%@/user/search", [GANUrlManager getBaseUrl]];
}

+ (NSString *) getEndpointForUserDetailsWithUserId: (NSString *) userId{
    return [NSString stringWithFormat:@"%@/user/%@", [GANUrlManager getBaseUrl], userId];
}

+ (NSString *) getEndpointForUserUpdateTypeWithUserId: (NSString *) userId{
    return [NSString stringWithFormat:@"%@/user/%@/type", [GANUrlManager getBaseUrl], userId];
}

+ (NSString *) getEndpointForUserUpdatePassword{
    return [NSString stringWithFormat:@"%@/user/password_recovery/reset", [GANUrlManager getBaseUrl]];
}

+ (NSString *) getEndPointForUserBulkSearch{
    return [NSString stringWithFormat:@"%@/user/bulksearch", [GANUrlManager getBaseUrl]];
}

#pragma mark - Endpoint for Job

+ (NSString *) getEndpointForAddJob{
    return [NSString stringWithFormat:@"%@/job", [GANUrlManager getBaseUrl]];
}

+ (NSString *) getEndpointForGetJobDetailsWithJobId: (NSString *) jobId{
    return [NSString stringWithFormat:@"%@/job/%@", [GANUrlManager getBaseUrl], jobId];
}

+ (NSString *) getEndpointForUpdateJobWithJobId: (NSString *) jobId{
    return [NSString stringWithFormat:@"%@/job/%@", [GANUrlManager getBaseUrl], jobId];
}

+ (NSString *) getEndpointForDeleteJobWithJobId: (NSString *) jobId{
    return [NSString stringWithFormat:@"%@/job/%@", [GANUrlManager getBaseUrl], jobId];
}

+ (NSString *) getEndpointForSearchJobs{
    return [NSString stringWithFormat:@"%@/job/search", [GANUrlManager getBaseUrl]];
}

#pragma mark - Endpoint for Application

+ (NSString *) getEndpointForGetApplications{
    return [NSString stringWithFormat:@"%@/application/search", [GANUrlManager getBaseUrl]];
}

+ (NSString *) getEndpointForApplyForJob{
    return [NSString stringWithFormat:@"%@/application", [GANUrlManager getBaseUrl]];
}

+ (NSString *) getEndpointForSuggestFriendForJob{
    return [NSString stringWithFormat:@"%@/suggest", [GANUrlManager getBaseUrl]];
}

#pragma mark - Endpoint for MyWorkers

+ (NSString *) getEndpointForGetMyWorkersWithCompanyId: (NSString *) companyId{
    return [NSString stringWithFormat:@"%@/company/%@/my-workers", [GANUrlManager getBaseUrl], companyId];
}

+ (NSString *) getEndpointForAddMyWorkersWithCompanyId: (NSString *) companyId{
    return [NSString stringWithFormat:@"%@/company/%@/my-workers", [GANUrlManager getBaseUrl], companyId];
}

+ (NSString *) getEndpointForUpdateMyWorkersNicknameWithCompanyId: (NSString *) companyId MyWorkerId: (NSString *) myWorkerId{
    return [NSString stringWithFormat:@"%@/company/%@/my-workers/%@", [GANUrlManager getBaseUrl], companyId, myWorkerId];
}

#pragma mark - Messages

+ (NSString *) getEndpointForGetMessages{
    return [NSString stringWithFormat:@"%@/message/search", [GANUrlManager getBaseUrl]];
}

+ (NSString *) getEndpointForSendMessage{
    return [NSString stringWithFormat:@"%@/message", [GANUrlManager getBaseUrl]];
}

+ (NSString *) getEndpointForMessageMarkAsRead{
    return [NSString stringWithFormat:@"%@/message/status-update", [GANUrlManager getBaseUrl]];
}

#pragma mark - Reviews

+ (NSString *) getEndpointForGetReviews{
    return [NSString stringWithFormat:@"%@/review/search", [GANUrlManager getBaseUrl]];
}

+ (NSString *) getEndpointForAddReview{
    return [NSString stringWithFormat:@"%@/review", [GANUrlManager getBaseUrl]];
}

#pragma mark - Recruit

+ (NSString *) getEndpointForSubmitRecruit{
    return [NSString stringWithFormat:@"%@/recruit", [GANUrlManager getBaseUrl]];
}

#pragma mark - Invite

+ (NSString *) getEndpointForInvite{
    return [NSString stringWithFormat:@"%@/invite", [GANUrlManager getBaseUrl]];
}

#pragma mark - Survey

+ (NSString *) getEndpointForGetSurveys{
    return [NSString stringWithFormat:@"%@/survey/search", [GANUrlManager getBaseUrl]];
}

+ (NSString *) getEndpointForCreateSurvey{
    return [NSString stringWithFormat:@"%@/survey", [GANUrlManager getBaseUrl]];
}

+ (NSString *) getEndpointForGetSurveyAnswers{
    return [NSString stringWithFormat:@"%@/survey/answer/search", [GANUrlManager getBaseUrl]];
}

+ (NSString *) getEndpointForSubmitSurveyAnswer{
    return [NSString stringWithFormat:@"%@/survey/answer", [GANUrlManager getBaseUrl]];
}

#pragma mark - Membership PLan

+ (NSString *) getEndpointForMembershipPlans{
    return [NSString stringWithFormat:@"%@/plans", [GANUrlManager getBaseUrl]];
}

#pragma mark - Google Translate

+ (NSString *) getEndpointForGoogleTranslate{
    return @"https://translation.googleapis.com/language/translate/v2";
}

+ (NSString *) getEndpointForStaticMap:(float)latitude longitue:(float)longitude {
    NSString *szUrl = [NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?center=%f,%f&zoom=18&size=600x360&markers=color:green%%7Clabel:%%7C%f,%f", latitude, longitude, latitude, longitude];
    return szUrl;
}

@end
