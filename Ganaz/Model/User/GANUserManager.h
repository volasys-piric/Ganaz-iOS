//
//  GANUserManager.h
//  Ganaz
//
//  Created by Piric Djordje on 3/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANUserWorkerDataModel.h"
#import "GANUserCompanyDataModel.h"
#import "GANCompanyDataModel.h"
#import "GANUserMinimumInfoDataModel.h"

@interface GANUserManager : NSObject

@property (strong, nonatomic) GANUserBaseDataModel *modelUser;
@property (strong, nonatomic) GANUserMinimumInfoDataModel *modelUserMinInfo;
@property (assign, atomic) NSInteger nNearbyWorkerCount;

+ (instancetype) sharedInstance;
- (void) initializeManagerWithType: (GANENUM_USER_TYPE) type;

+ (GANUserWorkerDataModel *) getUserWorkerDataModel;
+ (GANUserCompanyDataModel *) getUserCompanyDataModel;
+ (GANCompanyDataModel *) getCompanyDataModel;

#pragma mark - Utils

- (BOOL) isCompanyUser;
- (BOOL) isWorker;
- (NSString *) getAuthorizationHeader;
- (BOOL) isUserLoggedIn;
- (void) doLogout;

- (CLLocation *) getCurrentLocation;
- (NSInteger) getNearbyWorkerCount;

#pragma mark - Login & Signup

- (void) requestOnboardingUserSignupWithCallback: (void(^) (int status)) callback;
- (void) requestUserSignupWithCallback: (void (^) (int status)) callback;
- (void) requestUserLoginWithUsername: (NSString *) username Password: (NSString *) password Callback: (void (^) (int status)) callback;
- (void) requestUserLoginWithPhoneNumber: (NSString *) phoneNumber Password: (NSString *) password Callback: (void (^) (int status)) callback;
- (void) requestSearchUserByPhoneNumber: (NSString *) phoneNumber Type: (GANENUM_USER_TYPE) type Callback: (void (^) (int status, NSArray *array)) callback;
- (void) requestUserDetailsByUserId: (NSString *) userId Callback: (void (^) (int status, GANUserBaseDataModel *user)) callback;

- (void) requestUpdateMyLocationWithCallback: (void (^) (int status)) callback;
- (BOOL) loadFromLocalstorage;
- (BOOL) checkLocalstorageIfLastLoginSaved;
- (void) requestUpdateOneSignalPlayerIdWithCallback: (void (^) (int status)) callback;

// Reset Password

- (void) requestUpdatePassword: (NSString *) password WithCallback: (void (^) (int status)) callback;

- (void) requestUserBulkSearch:(float)radius WithCallback:(void (^) (int status)) callback;

@end
