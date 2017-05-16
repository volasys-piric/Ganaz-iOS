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

@interface GANUserManager : NSObject

@property (strong, nonatomic) GANUserBaseDataModel *modelUser;

+ (instancetype) sharedInstance;
- (void) initializeManagerWithType: (GANENUM_USER_TYPE) type;

+ (GANUserWorkerDataModel *) getUserWorkerDataModel;
+ (GANUserCompanyDataModel *) getUserCompanyDataModel;

#pragma mark - Utils

- (BOOL) isCompany;
- (BOOL) isWorker;
- (NSString *) getAuthorizationHeader;
- (BOOL) isUserLoggedIn;
- (void) doLogout;

- (CLLocation *) getCurrentLocation;

#pragma mark - Login & Signup

- (void) requestUserSignupWithCallback: (void (^) (int status)) callback;
- (void) requestUserLogin: (NSString *) username Password: (NSString *) password Callback: (void (^) (int status)) callback;
- (void) requestSearchUserByPhoneNumber: (NSString *) phoneNumber Type: (GANENUM_USER_TYPE) type Callback: (void (^) (int status, NSArray *array)) callback;
- (void) requestUserDetailsByUserId: (NSString *) userId Callback: (void (^) (int status, GANUserBaseDataModel *user)) callback;

- (void) requestUpdateMyLocationWithCallback: (void (^) (int status)) callback;
- (BOOL) checkLocalstorageIfLastLoginSaved;
- (void) requestUpdateOneSignalPlayerIdWithCallback: (void (^) (int status)) callback;

@end
