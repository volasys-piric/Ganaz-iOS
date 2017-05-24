//
//  GANReviewDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 3/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GANReviewDataModel : NSObject

@property (strong, nonatomic) NSString *szId;
@property (strong, nonatomic) NSString *szCompanyId;
@property (strong, nonatomic) NSString *szCompanyUserId;
@property (strong, nonatomic) NSString *szWorkerUserId;
@property (strong, nonatomic) NSString *szComments;
@property (assign, atomic) int ratingPay;
@property (assign, atomic) int ratingBenefits;
@property (assign, atomic) int ratingSupervisors;
@property (assign, atomic) int ratingSafety;
@property (assign, atomic) int ratingTrust;

- (instancetype) init;
- (void) setWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) serializeToDictionary;
- (int) getRatingAtIndex: (int) index;
- (void) setRating: (int) rating AtIndex: (int) index;
- (float) getAverageRating;

@end
