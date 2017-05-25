//
//  GANCompanyManager.m
//  Ganaz
//
//  Created by Piric Djordje on 5/24/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyManager.h"
#import "GANUrlManager.h"
#import "GANNetworkRequestManager.h"
#import "GANErrorManager.h"
#import "GANGenericFunctionManager.h"
#import "Global.h"

@implementation GANCompanyManager

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

+ (NSString *) generateCompanyCodeFromName: (NSString *) companyName{
    NSString *sz = [companyName lowercaseString];
    sz = [sz stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    sz = [sz stringByReplacingOccurrencesOfString:@"--" withString:@"-"];
    sz = [NSString stringWithFormat:@"%@-%@", sz, [GANGenericFunctionManager generateRandomString:4]];
    sz = [sz lowercaseString];
    return sz;
}

- (int) addCompanyIfNeeded: (GANCompanyDataModel *) company{
    int index = [self getIndexForCompanyByCompanyId:company.szId];
    if (index != -1) return index;
    
    [self.arrCompaniesFound addObject:company];
    return (int) [self.arrCompaniesFound count] - 1;
}

- (int) getIndexForCompanyByCompanyId: (NSString *) companyId{
    for (int i = 0; i < (int) [self.arrCompaniesFound count]; i++){
        GANCompanyDataModel *company = [self.arrCompaniesFound objectAtIndex:i];
        if ([company.szId isEqualToString:companyId] == YES) return i;
    }
    return -1;
}

- (int) getIndexForCompanyByCompanyCode: (NSString *) companyCode{
    for (int i = 0; i < (int) [self.arrCompaniesFound count]; i++){
        GANCompanyDataModel *company = [self.arrCompaniesFound objectAtIndex:i];
        if ([company.szCode caseInsensitiveCompare:companyCode] == NSOrderedSame) return i;
    }
    return -1;
}
- (void) getCompanyBusinessNameESByCompanyId: (NSString *) companyId Callback: (void (^) (NSString *businessNameES)) callback{
    int index = [self getIndexForCompanyByCompanyId:companyId];
    if (index != -1){
        GANCompanyDataModel *company = [self.arrCompaniesFound objectAtIndex:index];
        if (callback) callback([company getBusinessNameES]);
        return;
    }
    else {
        [self requestGetCompanyDetailsByCompanyId:companyId Callback:^(int indexCompany) {
            if (indexCompany != -1){
                GANCompanyDataModel *company = [self.arrCompaniesFound objectAtIndex:indexCompany];
                if (callback) callback([company getBusinessNameES]);
            }
            else {
                if (callback) callback(@"Unknown");
            }
        }];
    }
}

#pragma mark - Request

- (void) requestCreateCompany: (GANCompanyDataModel *) company Callback: (void (^) (int status, GANCompanyDataModel *companyNew)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForCreateCompany];
    NSDictionary *params = [company serializeToDictionary];
    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:NO parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            GANCompanyDataModel *companyNew = [[GANCompanyDataModel alloc] init];
            NSDictionary *dictCompany = [dict objectForKey:@"company"];
            [companyNew setWithDictionary:dictCompany];
            [self addCompanyIfNeeded:companyNew];
            
            if (callback) callback(SUCCESS_WITH_NO_ERROR, companyNew);
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage], nil);
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status, nil);
    }];
}

- (void) requestGetCompanyDetailsByCompanyId: (NSString *) companyId Callback: (void (^) (int indexCompany)) callback{
    int index = [self getIndexForCompanyByCompanyId:companyId];
    if (index != -1){
        if (callback) callback(index);
        return;
    }
    else {
        NSString *szUrl = [GANUrlManager getEndpointForGetCompanyDetailsByCompanyId:companyId];
        [[GANNetworkRequestManager sharedInstance] GET:szUrl requireAuth:NO parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *dict = responseObject;
            BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
            if (success){
                GANCompanyDataModel *company = [[GANCompanyDataModel alloc] init];
                NSDictionary *dictCompany = [dict objectForKey:@"company"];
                [company setWithDictionary:dictCompany];
                int indexCompany = [self addCompanyIfNeeded:company];
                
                if (callback) callback(indexCompany);
            }
            else {
                if (callback) callback(-1);
            }
        } failure:^(int status, NSDictionary *error) {
            if (callback) callback(-1);
        }];
    }
}

- (void) requestGetCompanyDetailsByCompanyCode: (NSString *) companyCode Callback: (void (^) (int indexCompany)) callback{
    int index = [self getIndexForCompanyByCompanyCode:companyCode];
    if (index != -1){
        if (callback) callback(index);
        return;
    }
    else {
        NSString *szUrl = [GANUrlManager getEndpointForSearchCompany];
        NSDictionary *param = @{@"code": companyCode};
        
        [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:NO parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *dict = responseObject;
            BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
            if (success){
                NSArray *arr = [dict objectForKey:@"companies"];
                for (int i = 0; i < (int) [arr count]; i++){
                    NSDictionary *dictCompany = [arr objectAtIndex:i];
                    GANCompanyDataModel *company = [[GANCompanyDataModel alloc] init];
                    [company setWithDictionary:dictCompany];
                    [self addCompanyIfNeeded:company];
                }
                int indexCompany = [self getIndexForCompanyByCompanyCode:companyCode];
                if (callback) callback(indexCompany);
            }
            else {
                if (callback) callback(-1);
            }
        } failure:^(int status, NSDictionary *error) {
            if (callback) callback(-1);
        }];
    }
}

@end
