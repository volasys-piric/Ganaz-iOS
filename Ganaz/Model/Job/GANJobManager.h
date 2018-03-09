//
//  GANJobManager.h
//  Ganaz
//
//  Created by Piric Djordje on 3/10/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANJobDataModel.h"
#import "GANJobApplicationDataModel.h"

// [Job: Candidate] Mapping...

@interface GANJobCandidatesMappingDataModel : NSObject

@property (strong, nonatomic) NSString *szJobId;
@property (strong, nonatomic) NSMutableArray <GANUserRefDataModel *> *arrayCandidates;

@end


// Job Manager

@interface GANJobManager : NSObject

/*
 @description: This property is used for "Company" user only. It will have the list of jobs posted by current user (company).
 */

@property (strong, nonatomic) NSMutableArray *arrMyJobs;
@property (strong, nonatomic) NSMutableArray <GANJobApplicationDataModel *> *arrayJobApplications;
@property (strong, nonatomic) NSMutableArray <GANJobCandidatesMappingDataModel *> *arrayJobCandidatesMapping;

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
- (void) addJobCandidateIfNeeded: (NSString *) jobId Candidate: (GANUserRefDataModel *) newCandidate;
- (GANJobCandidatesMappingDataModel *) getJobCandidatesMappingByJobId: (NSString *) jobId;
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

@end
