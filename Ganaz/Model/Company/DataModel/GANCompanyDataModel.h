//
//  GANCompanyDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 5/23/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANUtils.h"

@interface GANCompanyPlanDataModel : NSObject

@property (assign, atomic) GANENUM_MEMBERSHIPPLAN_TYPE type;
@property (strong, nonatomic) NSString *szTitle;
@property (assign, atomic) float fFee;
@property (assign, atomic) int nJobs;
@property (assign, atomic) int nRecruits;
@property (assign, atomic) int nMessages;
@property (strong, nonatomic) NSDate *dateStart;
@property (strong, nonatomic) NSDate *dateEnd;
@property (assign, atomic) BOOL isAutoRenewal;

- (void) setWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) serializeToDictionary;

@end

#pragma mark - Company Data Model

@interface GANCompanyDataModel : NSObject

@property (strong, nonatomic) NSString *szId;
@property (strong, nonatomic) GANTransContentsDataModel *modelName;
@property (strong, nonatomic) GANTransContentsDataModel *modelDescription;
@property (assign, atomic) BOOL isAutoTranslate;
@property (strong, nonatomic) NSString *szCode;
@property (strong, nonatomic) GANAddressDataModel *modelAddress;
@property (strong, nonatomic) GANCompanyPlanDataModel *modelPlan;

@property (assign, atomic) int nTotalReviews;
@property (assign, atomic) float fTotalAvgRating;
@property (assign, atomic) int nTotalJobs;
@property (assign, atomic) int nTotalRecruits;
@property (assign, atomic) int nTotalMessages;

@property (strong, nonatomic) NSMutableArray *arrJobs;
@property (assign, atomic) BOOL isJobListLoaded;

- (instancetype) init;
- (void) setWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) serializeToDictionary;

- (int) getIndexForJob: (NSString *) jobId;

- (void) requestJobsListWithCallback: (void (^) (int status)) callback;
- (GANENUM_COMPANY_BADGE_TYPE) getBadgeType;

- (NSString *) getBusinessNameEN;
- (NSString *) getBussinessNameES;
- (NSString *) getDescriptionEN;
- (NSString *) getDescriptionES;

@end
