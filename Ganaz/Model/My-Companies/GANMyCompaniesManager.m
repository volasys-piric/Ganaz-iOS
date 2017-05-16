//
//  GANMyCompaniesManager.m
//  Ganaz
//
//  Created by Piric Djordje on 3/17/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANMyCompaniesManager.h"
#import "GANUserManager.h"
#import "GANNetworkRequestManager.h"
#import "GANUrlManager.h"

#import "Global.h"
#import "GANGenericFunctionManager.h"
#import "GANErrorManager.h"

@implementation GANMyCompaniesManager

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
    self.arrCompaniesFound = [[NSMutableArray alloc] init];
}

- (int) addCompanyIfNeeded: (GANUserCompanyDataModel *) company{
    int index = [self getIndexForCompanyByCompanyUserId:company.szId];
    if (index != -1) return index;
    
    [self.arrCompaniesFound addObject:company];
    return (int) [self.arrCompaniesFound count] - 1;
}

- (int) getIndexForCompanyByCompanyUserId: (NSString *) companyUserId{
    for (int i = 0; i < (int) [self.arrCompaniesFound count]; i++){
        GANUserCompanyDataModel *company = [self.arrCompaniesFound objectAtIndex:i];
        if ([company.szId isEqualToString:companyUserId] == YES) return i;
    }
    return -1;
}

- (void) getCompanyBusinessNameByCompanyUserId: (NSString *) companyUserId Callback: (void (^) (NSString *businessName)) callback{
    int index = [self getIndexForCompanyByCompanyUserId:companyUserId];
    if (index != -1){
        GANUserCompanyDataModel *company = [self.arrCompaniesFound objectAtIndex:index];
        if (callback) callback(company.szBusinessName);
        return;
    }
    else {
        [self requestGetCompanyDetailsByCompanyUserId:companyUserId Callback:^(int index) {
            if (index != -1){
                GANUserCompanyDataModel *company = [self.arrCompaniesFound objectAtIndex:index];
                if (callback) callback(company.szBusinessName);
            }
            else {
                if (callback) callback(@"Unknown");
            }
        }];
    }
}

#pragma mark - Request

- (void) requestGetCompanyDetailsByCompanyUserId: (NSString *) companyUserId Callback: (void (^) (int index)) callback{
    int index = [self getIndexForCompanyByCompanyUserId:companyUserId];
    if (index != -1){
        if (callback) callback(index);
        return;
    }
    
    [[GANUserManager sharedInstance] requestUserDetailsByUserId:companyUserId Callback:^(int status, GANUserBaseDataModel *user) {
        if (status == SUCCESS_WITH_NO_ERROR && user != nil){
            int index = [self addCompanyIfNeeded:(GANUserCompanyDataModel *) user];
            if (callback) callback(index);
        }
        else {
            if (callback) callback(-1);
        }
    }];
}

@end
