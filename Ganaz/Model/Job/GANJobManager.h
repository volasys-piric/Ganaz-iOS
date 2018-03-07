//
//  GANJobManager.h
//  Ganaz
//
//  Created by Piric Djordje on 3/10/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANJobDataModel.h"

@interface GANJobManager : NSObject

/*
 @description: This property is used for "Company" user only. It will have the list of jobs posted by current user (company).
 */

@property (strong, nonatomic) NSMutableArray *arrMyJobs;
@property (assign, atomic) BOOL isMyJobsLoading;

@property (strong, nonatomic) GANJobDataModel *modelOnboardingJob;

/*
 @description: The following properties are used for "Workers" only.
 */

@property (strong, nonatomic) NSMutableArray *arrJobsSearchResult;
@property (strong, nonatomic) NSMutableArray *arrMyApplications;

+ (instancetype) sharedInstance;
- (void) initializeManager;
- (void) initializeOnboardingJobAtIndex: (int) index;

- (int) getIndexForMyJobsByJobId: (NSString *) jobId;
- (int) getIndexForMyApplicationsByJobId: (NSString *) jobId;
+ (BOOL) isValidJobId: (NSString *) jobId;

#pragma mark - Request For <Company> User

- (void) requestMyJobListWithCallback: (void (^) (int status)) callback;
- (void) requestAddJob: (GANJobDataModel *) job Callback: (void (^) (int status)) callback;
- (void) requestUpdateJobAtIndex: (int) index Job: (GANJobDataModel *) job Callback: (void (^) (int status)) callback;
- (void) requestDeleteJobAtIndex: (int) index Callback: (void (^) (int status)) callback;

#pragma mark - Request for <Worker> User

- (void) requestSearchJobsNearbyWithDistance: (float) distance Date: (NSDate *) date Callback: (void (^) (int status)) callback;
- (void) requestSearchJobsByCompanyId: (NSString *) companyUserId Callback: (void (^) (int status, NSArray *arrJobs)) callback;

#pragma mark - Worker > Application

- (void) requestApplyForJob: (NSString *) jobId Callback: (void (^) (int status)) callback;
- (void) requestSuggestFriendForJob: (NSString *) jobId PhoneNumber: (NSString *) phoneNumber Callback: (void (^) (int status)) callback;
- (void) requestGetMyApplicationsWithCallback: (void (^) (int status)) callback;
- (void) requestGetApplicantsByJobId: (NSString *) jobId Callback: (void (^) (NSArray <GANUserRefDataModel *> *applicants, int status)) callback;

@end
