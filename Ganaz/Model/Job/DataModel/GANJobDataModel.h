//
//  GANJobDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 3/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANUtils.h"

@interface GANJobDataModel : NSObject

@property (strong, nonatomic) NSString *szId;
@property (strong, nonatomic) NSString *szCompanyId;
@property (strong, nonatomic) NSString *szTitle;
@property (strong, nonatomic) NSString *szTitleTranslated;
@property (assign, atomic) float fPayRate;
@property (assign, atomic) GANENUM_PAY_UNIT enumPayUnit;
@property (strong, nonatomic) NSDate *dateFrom;
@property (strong, nonatomic) NSDate *dateTo;
@property (assign, atomic) int nPositions;
@property (assign, atomic) BOOL isBenefitTraining;
@property (assign, atomic) BOOL isBenefitHealth;
@property (assign, atomic) BOOL isBenefitHousing;
@property (assign, atomic) BOOL isBenefitTransportation;
@property (assign, atomic) BOOL isBenefitBonus;
@property (assign, atomic) BOOL isBenefitScholarships;
@property (strong, nonatomic) NSString *szComments;
@property (strong, nonatomic) NSString *szCommentsTranslated;

@property (assign, atomic) BOOL isAutoTranslate;

@property (strong, nonatomic) NSMutableArray *arrSite;

- (instancetype) init;
- (void) initializeWithJob: (GANJobDataModel *) job;
- (void) setWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) serializeToDictionary;
- (float) getNearestDistance;
- (GANLocationDataModel *) getNearestSite;
- (BOOL) isPayRateSpecified;

- (NSString *) getTranslatedComments;
- (NSString *) getTranslatedTitle;

@end
