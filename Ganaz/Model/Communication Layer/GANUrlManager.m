//
//  GANUrlManager.m
//  Ganaz
//
//  Created by Piric Djordje on 2/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANUrlManager.h"
#import "Global.h"

@implementation GANUrlManager

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
    return [NSString stringWithFormat:@"%@/company", GANURL_BASEURL];
}

+ (NSString *) getEndpointForGetCompanyDetailsByCompanyId: (NSString *) companyId{
    return [NSString stringWithFormat:@"%@/company/%@", GANURL_BASEURL, companyId];
}

+ (NSString *) getEndpointForSearchCompany{
    return [NSString stringWithFormat:@"%@/company", GANURL_BASEURL];
}

#pragma mark - Endpoint for User

+ (NSString *) getEndpointForUserSignup{
    return [NSString stringWithFormat:@"%@/user", GANURL_BASEURL];
}

+ (NSString *) getEndpointForUserLogin{
    return [NSString stringWithFormat:@"%@/user/login", GANURL_BASEURL];
}

+ (NSString *) getEndpointForUserUpdateProfile{
    return [NSString stringWithFormat:@"%@/user", GANURL_BASEURL];
}

+ (NSString *) getEndpointForUserSearch{
    return [NSString stringWithFormat:@"%@/user/search", GANURL_BASEURL];
}

+ (NSString *) getEndpointForUserDetailsWithUserId: (NSString *) userId{
    return [NSString stringWithFormat:@"%@/user/%@", GANURL_BASEURL, userId];
}

#pragma mark - Endpoint for Job

+ (NSString *) getEndpointForAddJob{
    return [NSString stringWithFormat:@"%@/job", GANURL_BASEURL];
}

+ (NSString *) getEndpointForGetJobDetailsWithJobId: (NSString *) jobId{
    return [NSString stringWithFormat:@"%@/job/%@", GANURL_BASEURL, jobId];
}

+ (NSString *) getEndpointForUpdateJobWithJobId: (NSString *) jobId{
    return [NSString stringWithFormat:@"%@/job/%@", GANURL_BASEURL, jobId];
}

+ (NSString *) getEndpointForDeleteJobWithJobId: (NSString *) jobId{
    return [NSString stringWithFormat:@"%@/job/%@", GANURL_BASEURL, jobId];
}

+ (NSString *) getEndpointForSearchJobs{
    return [NSString stringWithFormat:@"%@/job/search", GANURL_BASEURL];
}

#pragma mark - Endpoint for Application

+ (NSString *) getEndpointForGetApplications{
    return [NSString stringWithFormat:@"%@/application", GANURL_BASEURL];
}

+ (NSString *) getEndpointForApplyForJob{
    return [NSString stringWithFormat:@"%@/application", GANURL_BASEURL];
}

#pragma mark - Endpoint for MyWorkers

+ (NSString *) getEndpointForGetMyWorkersWithCompanyId: (NSString *) companyId{
    return [NSString stringWithFormat:@"%@/company/%@/my-workers", GANURL_BASEURL, companyId];
}

+ (NSString *) getEndpointForAddMyWorkersWithCompanyId: (NSString *) companyId{
    return [NSString stringWithFormat:@"%@/company/%@/my-workers", GANURL_BASEURL, companyId];
}

#pragma mark - Messages

+ (NSString *) getEndpointForGetMessages{
    return [NSString stringWithFormat:@"%@/message", GANURL_BASEURL];
}

+ (NSString *) getEndpointForSendMessage{
    return [NSString stringWithFormat:@"%@/message", GANURL_BASEURL];
}

#pragma mark - Reviews

+ (NSString *) getEndpointForGetReviews{
    return [NSString stringWithFormat:@"%@/review/search", GANURL_BASEURL];
}

+ (NSString *) getEndpointForAddReview{
    return [NSString stringWithFormat:@"%@/review", GANURL_BASEURL];
}

#pragma mark - Recruit

+ (NSString *) getEndpointForSubmitRecruit{
    return [NSString stringWithFormat:@"%@/recruit", GANURL_BASEURL];
}

#pragma mark - Invite

+ (NSString *) getEndpointForInvite{
    return [NSString stringWithFormat:@"%@/invite", GANURL_BASEURL];
}

#pragma mark - Membership PLan

+ (NSString *) getEndpointForMembershipPlans{
    return [NSString stringWithFormat:@"%@/plans", GANURL_BASEURL];
}

#pragma mark - Google Translate

+ (NSString *) getEndpointForGoogleTranslate{
    return @"https://translation.googleapis.com/language/translate/v2";
}

@end
