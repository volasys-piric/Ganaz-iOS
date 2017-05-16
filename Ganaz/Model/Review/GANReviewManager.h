//
//  GANReviewManager.h
//  Ganaz
//
//  Created by Piric Djordje on 3/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANReviewDataModel.h"

@interface GANReviewManager : NSObject

@property (strong, nonatomic) NSMutableArray *arrReviews;

+ (instancetype) sharedInstance;
- (void) initializeManager;

#pragma mark - Utils

- (int) getIndexForReviewByCompanyUserId: (NSString *) companyUserId;

#pragma mark - Request

- (void) requestGetReviewsListWithCallback: (void (^) (int status)) callback;
- (void) requestAddReview: (GANReviewDataModel *) review Callback: (void (^) (int status)) callback;

@end
