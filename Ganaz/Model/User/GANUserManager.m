//
//  GANUserManager.m
//  Ganaz
//
//  Created by Piric Djordje on 3/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANUserManager.h"
#import "GANNetworkRequestManager.h"
#import "GANUrlManager.h"
#import "GANLocationManager.h"
#import "GANGenericFunctionManager.h"
#import "GANErrorManager.h"
#import "GANLocalstorageManager.h"
#import "GANPushNotificationManager.h"
#import "Global.h"

@implementation GANUserManager

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
    }
    return self;
}

- (void) initializeManagerWithType: (GANENUM_USER_TYPE) type{
    if (type == GANENUM_USER_TYPE_WORKER){
        self.modelUser = [[GANUserWorkerDataModel alloc] init];
    }
    else if (type == GANENUM_USER_TYPE_COMPANY_REGULAR || type == GANENUM_USER_TYPE_COMPANY_ADMIN){
        self.modelUser = [[GANUserCompanyDataModel alloc] init];
    }
    self.modelUser.enumType = type;
}

+ (GANUserWorkerDataModel *) getUserWorkerDataModel{
    return (GANUserWorkerDataModel *) [GANUserManager sharedInstance].modelUser;
}

+ (GANUserCompanyDataModel *) getUserCompanyDataModel{
    return (GANUserCompanyDataModel *) [GANUserManager sharedInstance].modelUser;
}

+ (GANCompanyDataModel *) getCompanyDataModel{
    return [self getUserCompanyDataModel].modelCompany;
}

- (BOOL) isUserLoggedIn{
    return (self.modelUser != nil);
}

- (void) doLogout{
    self.modelUser = nil;
    [self removeFromLocalstorage];
}

- (void) saveToLocalstorage{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.modelUser.szUserName forKey:@"username"];
    [dict setObject:self.modelUser.szPassword forKey:@"password"];
    [GANLocalstorageManager saveGlobalObject:dict Key:LOCALSTORAGE_USER_LOGIN];
}

- (void) loadFromLocalstorage{
    NSDictionary *dict = [GANLocalstorageManager loadGlobalObjectWithKey:LOCALSTORAGE_USER_LOGIN];
    self.modelUser.szUserName = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"username"]];
    self.modelUser.szPassword = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"password"]];
}

- (void) removeFromLocalstorage{
    [GANLocalstorageManager saveGlobalObject:nil Key:LOCALSTORAGE_USER_LOGIN];
}

#pragma mark - Utils

- (BOOL) isCompanyUser{
    return ((self.modelUser.enumType == GANENUM_USER_TYPE_COMPANY_REGULAR) ||
            (self.modelUser.enumType == GANENUM_USER_TYPE_COMPANY_ADMIN));
}

- (BOOL) isWorker{
    return (self.modelUser.enumType == GANENUM_USER_TYPE_WORKER);
}

- (NSString *) getAuthorizationHeader{
    return self.modelUser.szAccessToken;
}

- (CLLocation *) getCurrentLocation{
    CLLocation *location = [GANLocationManager sharedInstance].location;
    if ([self isUserLoggedIn] == YES && [self isWorker] == YES){
        location = [[GANUserManager getUserWorkerDataModel].modelLocation generateCLLocation];
    }
    return location;
}

#pragma mark - Login & Signup

- (void) requestUserSignupWithCallback: (void (^) (int status)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForUserSignup];
    NSDictionary *params = [self.modelUser serializeToDictionary];
    
    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:NO parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        GANLOG(@"User Signup Response ===> %@", responseObject);
        NSDictionary *dict = responseObject;
        NSString *szPassword = self.modelUser.szPassword;
        
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSDictionary *dictAccount = [dict objectForKey:@"account"];
            [self.modelUser setWithDictionary:dictAccount];
            self.modelUser.szPassword = szPassword;
            [self saveToLocalstorage];
            
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

- (void) requestUserLogin: (NSString *) username Password: (NSString *) password Callback: (void (^) (int status)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForUserLogin];
    NSDictionary *params = @{@"username": username,
                            @"password": password,
                            @"auth_type": @"email",
                            };
    
    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:NO parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        GANLOG(@"User Login Response ===> %@", responseObject);
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSDictionary *dictAccount = [dict objectForKey:@"account"];
            NSString *szUserType = [GANGenericFunctionManager refineNSString: [dictAccount objectForKey:@"type"]];
            GANENUM_USER_TYPE enumUserType = [GANUtils getUserTypeFromString:szUserType];
            [self initializeManagerWithType:enumUserType];
            [self.modelUser setWithDictionary:dictAccount];
            self.modelUser.szPassword = password;
            [self saveToLocalstorage];
            
            GANPushNotificationManager *managerPush = [GANPushNotificationManager sharedInstance];
            if (managerPush.szOneSignalPlayerId.length > 0 && [self.modelUser.szPlayerId isEqualToString:managerPush.szOneSignalPlayerId] == NO){
                self.modelUser.szPlayerId = managerPush.szOneSignalPlayerId;
                [self requestUpdateOneSignalPlayerIdWithCallback:nil];
            }
            
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

- (void) requestSearchUserByPhoneNumber: (NSString *) phoneNumber Type: (GANENUM_USER_TYPE) type Callback: (void (^) (int status, NSArray *array)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForUserSearch];
    NSDictionary *params = @{@"type": [GANUtils getStringFromUserType:type],
                            @"phone_number": phoneNumber
                            };
    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:YES parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSArray *arrFound = [dict objectForKey:@"users"];
            if (callback) callback(SUCCESS_WITH_NO_ERROR, arrFound);
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage], nil);
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status, nil);
    }];
}

- (void) requestUserDetailsByUserId: (NSString *) userId Callback: (void (^) (int status, GANUserBaseDataModel *user)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForUserDetailsWithUserId:userId];
    [[GANNetworkRequestManager sharedInstance] GET:szUrl requireAuth:NO parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSDictionary *dictAccount = [dict objectForKey:@"account"];
            NSString *szUserType = [GANGenericFunctionManager refineNSString: [dictAccount objectForKey:@"type"]];
            GANENUM_USER_TYPE enumUserType = [GANUtils getUserTypeFromString:szUserType];
            GANUserBaseDataModel *user;
            
            if (enumUserType == GANENUM_USER_TYPE_WORKER){
                user = [[GANUserWorkerDataModel alloc] init];
                [user setWithDictionary:dictAccount];
            }
            else {
                user = [[GANUserCompanyDataModel alloc] init];
                [user setWithDictionary:dictAccount];
            }
            if (callback) callback(SUCCESS_WITH_NO_ERROR, user);
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage], nil);
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status, nil);
    }];
}

- (void) requestUpdateMyLocationWithCallback: (void (^) (int status)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForUserUpdateProfile];
    GANUserWorkerDataModel *me = [GANUserManager getUserWorkerDataModel];
    
    NSDictionary *params = @{@"account": @{@"worker": @{@"location": [me.modelLocation serializeToDictionary],
                                                        @"is_newjob_lock": (me.isNewJobLock == YES) ? @"true" : @"false"}}};
    
    [[GANNetworkRequestManager sharedInstance] PATCH:szUrl requireAuth:YES parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
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

- (void) requestUpdateOneSignalPlayerIdWithCallback: (void (^) (int status)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForUserUpdateProfile];
    NSDictionary *params = @{@"account": @{@"player_id": [GANPushNotificationManager sharedInstance].szOneSignalPlayerId}};

    
    [[GANNetworkRequestManager sharedInstance] PATCH:szUrl requireAuth:YES parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
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

- (void) requestSilentLoginWithLastUserInfoIfPossibleWithCallback: (void (^)(int status)) callback{
    NSDictionary *dict = [GANLocalstorageManager loadGlobalObjectWithKey:LOCALSTORAGE_USER_LOGIN];
    NSString *szUserName = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"username"]];
    NSString *szPassword = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"password"]];
    
    if (szUserName.length > 0 && szPassword.length > 0){
        [self requestUserLogin:szUserName Password:szPassword Callback:^(int status) {
            if (status == SUCCESS_WITH_NO_ERROR){
                [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_USER_SILENTLOGIN_SUCCEEDED object:nil];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_USER_SILENTLOGIN_FAILED object:nil];
            }
            if (callback) callback(status);
        }];
    }
    else {
        if (callback) callback(ERROR_UNAUTHORIZED);
    }
}

- (BOOL) checkLocalstorageIfLastLoginSaved{
    NSDictionary *dict = [GANLocalstorageManager loadGlobalObjectWithKey:LOCALSTORAGE_USER_LOGIN];
    if (dict == nil || ([dict isKindOfClass: [NSNull class]] == YES)) return NO;
    
    NSString *szUserName = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"username"]];
    NSString *szPassword = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"password"]];
    if (szUserName.length > 0 && szPassword.length > 0) return YES;
    return NO;
}

@end
