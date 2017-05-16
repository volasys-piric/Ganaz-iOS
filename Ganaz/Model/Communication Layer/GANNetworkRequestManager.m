//
//  GANNetworkRequestManager.m
//  Ganaz
//
//  Created by Piric Djordje on 2/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANNetworkRequestManager.h"
#import "GANUserManager.h"
#import "GANErrorManager.h"
#import "GANGenericFunctionManager.h"
#import "Global.h"
#import <AFNetworking.h>

@implementation GANNetworkRequestManager

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
}

- (void) GET: (NSString *) szUrl requireAuth: (BOOL) requireAuth parameters: (id) params success:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock failure:(void (^)(int status, NSDictionary *error))failureBlock {
    AFHTTPSessionManager *managerAFSession = [AFHTTPSessionManager manager];
    managerAFSession.requestSerializer = [AFJSONRequestSerializer serializer];
    managerAFSession.responseSerializer = [AFJSONResponseSerializer serializer];
    
    if (requireAuth == YES){
        [managerAFSession.requestSerializer setValue:[[GANUserManager sharedInstance] getAuthorizationHeader] forHTTPHeaderField:@"Authorization"];
    }
    
    NSString *token = [GANGenericFunctionManager generateRandomString:16];
    GANLOG(@"Network Request =>\nGET: %@\nParams: %@\nToken: %@", szUrl, params, token);
    [managerAFSession GET:szUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GANLOG(@"Request Succeeded: Token = %@", token);
        if (successBlock) successBlock(task, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSDictionary *dictError = [GANErrorManager getResponseObjectFromAFError:error];
        int status = [[GANErrorManager sharedInstance] analyzeErrorResponseWithURLResponse:(NSHTTPURLResponse *)task.response Error:error ResponseObject:dictError];
        GANLOG(@"Request Failed: Error Code = %d, Token = %@, Error Description = %@", status, token, [GANErrorManager sharedInstance].szDescription);
        
        if (failureBlock) failureBlock(status, dictError);
    }];
}

- (void) POST: (NSString *) szUrl requireAuth: (BOOL) requireAuth parameters: (id) params success:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock failure:(void (^)(int status, NSDictionary *error))failureBlock {
    AFHTTPSessionManager *managerAFSession = [AFHTTPSessionManager manager];
    managerAFSession.requestSerializer = [AFJSONRequestSerializer serializer];
    managerAFSession.responseSerializer = [AFJSONResponseSerializer serializer];
    
    if (requireAuth == YES){
        [managerAFSession.requestSerializer setValue:[[GANUserManager sharedInstance] getAuthorizationHeader] forHTTPHeaderField:@"Authorization"];
    }
    
    NSString *token = [GANGenericFunctionManager generateRandomString:16];
    GANLOG(@"Network Request =>\nPOST: %@\nParams: %@\nToken: %@", szUrl, params, token);
    [managerAFSession POST:szUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GANLOG(@"Request Succeeded: Token = %@", token);
        if (successBlock) successBlock(task, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSDictionary *dictError = [GANErrorManager getResponseObjectFromAFError:error];
        int status = [[GANErrorManager sharedInstance] analyzeErrorResponseWithURLResponse:(NSHTTPURLResponse *)task.response Error:error ResponseObject:dictError];
        GANLOG(@"Request Failed: Error Code = %d, Token = %@, Error Description = %@", status, token, [GANErrorManager sharedInstance].szDescription);
        
        if (failureBlock) failureBlock(status, dictError);
    }];
}

- (void) PUT: (NSString *) szUrl requireAuth: (BOOL) requireAuth parameters: (id) params success:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock failure:(void (^)(int status, NSDictionary *error))failureBlock {
    AFHTTPSessionManager *managerAFSession = [AFHTTPSessionManager manager];
    managerAFSession.requestSerializer = [AFJSONRequestSerializer serializer];
    managerAFSession.responseSerializer = [AFJSONResponseSerializer serializer];
    
    if (requireAuth == YES){
        [managerAFSession.requestSerializer setValue:[[GANUserManager sharedInstance] getAuthorizationHeader] forHTTPHeaderField:@"Authorization"];
    }
    
    NSString *token = [GANGenericFunctionManager generateRandomString:16];
    GANLOG(@"Network Request =>\nPUT: %@\nParams: %@\nToken: %@", szUrl, params, token);
    [managerAFSession PUT:szUrl parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GANLOG(@"Request Succeeded: Token = %@", token);
        if (successBlock) successBlock(task, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSDictionary *dictError = [GANErrorManager getResponseObjectFromAFError:error];
        int status = [[GANErrorManager sharedInstance] analyzeErrorResponseWithURLResponse:(NSHTTPURLResponse *)task.response Error:error ResponseObject:dictError];
        GANLOG(@"Request Failed: Error Code = %d, Token = %@, Error Description = %@", status, token, [GANErrorManager sharedInstance].szDescription);
        
        if (failureBlock) failureBlock(status, dictError);
    }];
}

- (void) PATCH: (NSString *) szUrl requireAuth: (BOOL) requireAuth parameters: (id) params success:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock failure:(void (^)(int status, NSDictionary *error))failureBlock {
    AFHTTPSessionManager *managerAFSession = [AFHTTPSessionManager manager];
    managerAFSession.requestSerializer = [AFJSONRequestSerializer serializer];
    managerAFSession.responseSerializer = [AFJSONResponseSerializer serializer];
    
    if (requireAuth == YES){
        [managerAFSession.requestSerializer setValue:[[GANUserManager sharedInstance] getAuthorizationHeader] forHTTPHeaderField:@"Authorization"];
    }
    
    NSString *token = [GANGenericFunctionManager generateRandomString:16];
    GANLOG(@"Network Request =>\nPATCH: %@\nParams: %@\nToken: %@", szUrl, params, token);
    [managerAFSession PATCH:szUrl parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GANLOG(@"Request Succeeded: Token = %@", token);
        if (successBlock) successBlock(task, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSDictionary *dictError = [GANErrorManager getResponseObjectFromAFError:error];
        int status = [[GANErrorManager sharedInstance] analyzeErrorResponseWithURLResponse:(NSHTTPURLResponse *)task.response Error:error ResponseObject:dictError];
        GANLOG(@"Request Failed: Error Code = %d, Token = %@, Error Description = %@", status, token, [GANErrorManager sharedInstance].szDescription);
        
        if (failureBlock) failureBlock(status, dictError);
    }];
}


- (void) DELETE: (NSString *) szUrl requireAuth: (BOOL) requireAuth parameters: (id) params success:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock failure:(void (^)(int status, NSDictionary *error))failureBlock {
    AFHTTPSessionManager *managerAFSession = [AFHTTPSessionManager manager];
    managerAFSession.requestSerializer = [AFJSONRequestSerializer serializer];
    managerAFSession.responseSerializer = [AFJSONResponseSerializer serializer];
    
    if (requireAuth == YES){
        [managerAFSession.requestSerializer setValue:[[GANUserManager sharedInstance] getAuthorizationHeader] forHTTPHeaderField:@"Authorization"];
    }
    
    NSString *token = [GANGenericFunctionManager generateRandomString:16];
    GANLOG(@"Network Request =>\nDELETE: %@\nParams: %@\nToken: %@", szUrl, params, token);
    [managerAFSession DELETE:szUrl parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GANLOG(@"Request Succeeded: Token = %@", token);
        if (successBlock) successBlock(task, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSDictionary *dictError = [GANErrorManager getResponseObjectFromAFError:error];
        int status = [[GANErrorManager sharedInstance] analyzeErrorResponseWithURLResponse:(NSHTTPURLResponse *)task.response Error:error ResponseObject:dictError];
        GANLOG(@"Request Failed: Error Code = %d, Token = %@, Error Description = %@", status, token, [GANErrorManager sharedInstance].szDescription);
        
        if (failureBlock) failureBlock(status, dictError);
    }];
}

@end
