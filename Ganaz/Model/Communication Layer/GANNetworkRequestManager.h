//
//  GANNetworkRequestManager.h
//  Ganaz
//
//  Created by Piric Djordje on 2/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GANNetworkRequestManager : NSObject

+ (instancetype) sharedInstance;
- (void) initializeManager;

- (void) GET: (NSString *) szUrl requireAuth: (BOOL) requireAuth parameters: (id) params success:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock failure:(void (^)(int status, NSDictionary *error))failureBlock;
- (void) POST: (NSString *) szUrl requireAuth: (BOOL) requireAuth parameters: (id) params success:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock failure:(void (^)(int status, NSDictionary *error))failureBlock;
- (void) PATCH: (NSString *) szUrl requireAuth: (BOOL) requireAuth parameters: (id) params success:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock failure:(void (^)(int status, NSDictionary *error))failureBlock;
- (void) PUT: (NSString *) szUrl requireAuth: (BOOL) requireAuth parameters: (id) params success:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock failure:(void (^)(int status, NSDictionary *error))failureBlock;
- (void) DELETE: (NSString *) szUrl requireAuth: (BOOL) requireAuth parameters: (id) params success:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock failure:(void (^)(int status, NSDictionary *error))failureBlock;

@end
