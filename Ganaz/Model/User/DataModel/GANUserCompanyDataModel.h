//
//  GANUserCompanyDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 3/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANUserBaseDataModel.h"

@interface GANUserCompanyDataModel : GANUserBaseDataModel

@property (strong, nonatomic) NSString *szBusinessName;
@property (strong, nonatomic) NSString *szBusinessNameTranslated;
@property (strong, nonatomic) NSString *szDescription;
@property (strong, nonatomic) NSString *szDescriptionTranslated;

@property (strong, nonatomic) GANAddressDataModel *modelAddress;
@property (assign, atomic) int nTotalReviews;
@property (assign, atomic) float fTotalAvgRating;
@property (assign, atomic) BOOL isAutoTranslate;

@property (strong, nonatomic) NSMutableArray *arrJobs;
@property (assign, atomic) BOOL isJobListLoaded;

- (instancetype) init;
- (void) setWithDictionary: (NSDictionary *) dict;
- (int) getIndexForJob: (NSString *) jobId;

- (void) requestJobsListWithCallback: (void (^) (int status)) callback;
- (GANENUM_COMPANY_BADGE_TYPE) getBadgeType;

- (NSString *) getTranslatedBusinessName;
- (NSString *) getTranslatedDescription;

@end
