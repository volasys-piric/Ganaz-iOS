//
//  GANUserWorkerDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 3/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANUserBaseDataModel.h"

@interface GANUserWorkerDataModel : GANUserBaseDataModel

@property (strong, nonatomic) GANLocationDataModel *modelLocation;
@property (assign, atomic) BOOL isNewJobLock;

@property (assign, atomic) BOOL isJobSearchLock;
@property (strong, nonatomic) NSMutableArray <NSString *> *arrayJobSearchAllowedCompanyIds;

@property (assign, atomic) int indexForCandidate;              // Increasing index among the Candidates
@property (strong, nonatomic) NSString *szFacebookPSID;
@property (strong, nonatomic) NSString *szFacebookPageId;
@property (strong, nonatomic) NSString *szFacebookAdsId;
@property (strong, nonatomic) NSString *szFacebookCompanyId;
@property (strong, nonatomic) NSString *szFacebookJobId;

- (instancetype) init;
- (void) setWithDictionary: (NSDictionary *) dict;

@end
