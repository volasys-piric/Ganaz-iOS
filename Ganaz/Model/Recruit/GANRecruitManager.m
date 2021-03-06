//
//  GANRecruitManager.m
//  Ganaz
//
//  Created by Piric Djordje on 3/23/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANRecruitManager.h"

#import "GANUserManager.h"
#import "GANNetworkRequestManager.h"
#import "GANUrlManager.h"
#import "GANGenericFunctionManager.h"
#import "GANErrorManager.h"
#import "Global.h"

@implementation GANRecruitManager

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
    self.arrRecruits = [[NSMutableArray alloc] init];
}

- (int) addRecruitIfNeeded: (GANRecruitDataModel *) recruitNew{
    for (int i = 0; i < (int) [self.arrRecruits count]; i++){
        GANRecruitDataModel *recruit = [self.arrRecruits objectAtIndex:i];
        if ([recruit.szId isEqualToString:recruitNew.szId] == YES) return i;
    }
    [self.arrRecruits addObject:recruitNew];
    return (int) [self.arrRecruits count] - 1;
}

#pragma mark - Request

- (void) requestSubmitRecruitWithJobIds: (NSArray *) arrJobIds Broadcast: (float) fBroadcast ReRecruitUserIds: (NSArray *) arrReRecruitUserIds Phones:(NSArray <GANPhoneDataModel *> *) arrPhones Callback: (void (^) (int status, int count)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForSubmitRecruit];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:arrJobIds forKey:@"job_ids"];
    if (fBroadcast > 0){
        [params setObject:[NSString stringWithFormat:@"%.02f", fBroadcast] forKey:@"broadcast_radius"];
    }
    if ([arrReRecruitUserIds count] > 0){
        [params setObject:arrReRecruitUserIds forKey:@"re_recruit_worker_user_ids"];
    }
    
    if([arrPhones count] > 0) {
        NSMutableArray *arrayPhoneNumbers = [[NSMutableArray alloc] init];
        for (GANPhoneDataModel *phone in arrPhones) {
            [arrayPhoneNumbers addObject:[phone getNormalizedPhoneNumber]];
        }
        [params setObject:arrayPhoneNumbers forKey:@"phone_numbers"];
    }
        
    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:YES parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSArray *arrRecruits = [dict objectForKey:@"recruits"];
            int totalRecruits = 0;
            if ([arrRecruits isKindOfClass:[NSArray class]] == YES){
                for (int i = 0; i < (int) [arrRecruits count]; i++){
                    NSDictionary *dictRecruit = [arrRecruits objectAtIndex:i];
                    GANRecruitDataModel *recruitNew = [[GANRecruitDataModel alloc] init];
                    [recruitNew setWithDictionary:dictRecruit];
                    [self addRecruitIfNeeded:recruitNew];
                    totalRecruits = totalRecruits + [recruitNew getNumberOfRecruitedUsers];
                }
            }
            if (callback) callback(SUCCESS_WITH_NO_ERROR, totalRecruits);
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage], 0);
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status, 0);
    }];
}

@end
