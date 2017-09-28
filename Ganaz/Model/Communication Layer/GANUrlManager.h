//
//  GANUrlManager.h
//  Ganaz
//
//  Created by Piric Djordje on 2/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GANUrlManager : NSObject

#pragma mark - Endpoint for AppSettings

+ (NSString *) getEndpointForAppConfig;

#pragma mark - Endpoint for Location

+ (NSString *) getEndpointForGooglemapsGeocode;
+ (NSString *) getEndpointForGooglemapsPlaceAutoComplete;
+ (NSString *) getEndpointForGooglemapsPlaceDetails;
+ (NSString *) getEndpointForGooglemapsDirections;

#pragma mark - Endpoint for Company

+ (NSString *) getEndpointForCreateCompany;
+ (NSString *) getEndpointForGetCompanyDetailsByCompanyId: (NSString *) companyId;
+ (NSString *) getEndpointForSearchCompany;

#pragma mark - Endpoint for User

+ (NSString *) getEndpointForUserDetailsWithUserId: (NSString *) userId;
+ (NSString *) getEndpointForOnboardingUserSignup:(NSString *)szUserId;
+ (NSString *) getEndpointForUserSignup;
+ (NSString *) getEndpointForUserLogin;
+ (NSString *) getEndpointForUserUpdateProfile;
+ (NSString *) getEndpointForUserSearch;
+ (NSString *) getEndpointForUserUpdateTypeWithUserId: (NSString *) userId;
+ (NSString *) getEndpointForUserUpdatePassword;
+ (NSString *) getEndPointForUserBulkSearch;

#pragma mark - Endpoint for Job

+ (NSString *) getEndpointForSearchJobs;
+ (NSString *) getEndpointForGetJobDetailsWithJobId: (NSString *) jobId;
+ (NSString *) getEndpointForAddJob;
+ (NSString *) getEndpointForUpdateJobWithJobId: (NSString *) jobId;
+ (NSString *) getEndpointForDeleteJobWithJobId: (NSString *) jobId;

#pragma mark - Endpoint for Application

+ (NSString *) getEndpointForGetApplications;
+ (NSString *) getEndpointForApplyForJob;
+ (NSString *) getEndpointForSuggestFriendForJob;

#pragma mark - Endpoint for MyWorkers

+ (NSString *) getEndpointForGetMyWorkersWithCompanyId: (NSString *) companyId;
+ (NSString *) getEndpointForAddMyWorkersWithCompanyId: (NSString *) companyId;
+ (NSString *) getEndpointForUpdateMyWorkersNicknameWithCompanyId: (NSString *) companyId MyWorkerId: (NSString *) myWorkerId;

#pragma mark - Messages

+ (NSString *) getEndpointForGetMessages;
+ (NSString *) getEndpointForSendMessage;
+ (NSString *) getEndpointForMessageMarkAsRead;

#pragma mark - Reviews

+ (NSString *) getEndpointForGetReviews;
+ (NSString *) getEndpointForAddReview;

#pragma mark - Recruit

+ (NSString *) getEndpointForSubmitRecruit;

#pragma mark - Invite

+ (NSString *) getEndpointForInvite;

#pragma mark - Membership PLan

+ (NSString *) getEndpointForMembershipPlans;

#pragma mark - Google Translate

+ (NSString *) getEndpointForGoogleTranslate;

#pragma mark - Google Static Map API

+ (NSString *) getEndpointForStaticMap:(float)latitude longitue:(float)longitude;

@end
