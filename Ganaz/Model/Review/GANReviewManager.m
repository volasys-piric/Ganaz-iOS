//
//  GANReviewManager.m
//  Ganaz
//
//  Created by Piric Djordje on 3/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANReviewManager.h"

#import "GANUserManager.h"
#import "GANNetworkRequestManager.h"
#import "GANUrlManager.h"
#import "GANGenericFunctionManager.h"
#import "GANErrorManager.h"
#import "GANUtils.h"
#import "Global.h"

@implementation GANReviewManager

+ (instancetype) sharedInstance{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init{
    if (self = [super init]){
        [self initializeManager];
    }
    return self;
}

- (void) initializeManager{
    self.arrReviews = [[NSMutableArray alloc] init];
}

- (int) addReviewIfNeeded: (GANReviewDataModel *) reviewNew{
    for (int i = 0; i < (int) [self.arrReviews count]; i++){
        GANReviewDataModel *review = [self.arrReviews objectAtIndex:i];
        if ([review.szId isEqualToString:reviewNew.szId] == YES) return i;
    }
    [self.arrReviews addObject:reviewNew];
    return (int) [self.arrReviews count] - 1;
}

- (int) getIndexForReviewByCompanyUserId: (NSString *) companyUserId{
    for (int i = 0; i < (int) [self.arrReviews count]; i++){
        GANReviewDataModel *review = [self.arrReviews objectAtIndex:i];
        if ([review.szCompanyUserId isEqualToString:companyUserId] == YES) return i;
    }
    return -1;
}

#pragma mark - Request

- (void) requestGetReviewsListWithCallback: (void (^) (int status)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForGetReviews];
    [[GANNetworkRequestManager sharedInstance] GET:szUrl requireAuth:YES parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSArray *arrReviews = [dict objectForKey:@"reviews"];
            [self.arrReviews removeAllObjects];
            
            for (int i = 0; i < (int) [arrReviews count]; i++){
                NSDictionary *dictReview = [arrReviews objectAtIndex:i];
                GANReviewDataModel *review = [[GANReviewDataModel alloc] init];
                [review setWithDictionary:dictReview];
                [self.arrReviews addObject:review];
            }
            
            if (callback) callback(SUCCESS_WITH_NO_ERROR);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_REVIEW_LIST_UPDATED object:nil];
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_REVIEW_LIST_UPDATE_FAILED object:nil];
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_REVIEW_LIST_UPDATE_FAILED object:nil];
    }];
}

- (void) requestAddReview: (GANReviewDataModel *) review Callback: (void (^) (int status)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForGetReviews];
    NSDictionary *params = [review serializeToDictionary];
    
    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:YES parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSDictionary *dictReview = [dict objectForKey:@"review"];
            GANReviewDataModel *reviewNew = [[GANReviewDataModel alloc] init];
            [reviewNew setWithDictionary:dictReview];
            [self addReviewIfNeeded:reviewNew];
            
            if (callback) callback(SUCCESS_WITH_NO_ERROR);
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
    }];
}

@end
