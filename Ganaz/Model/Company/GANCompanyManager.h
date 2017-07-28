//
//  GANCompanyManager.h
//  Ganaz
//
//  Created by Piric Djordje on 5/24/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANCompanyDataModel.h"
#import "GANUserCompanyDataModel.h"
#import "GANMyWorkerDataModel.h"

@interface GANCompanyManager : NSObject

@property (strong, nonatomic) NSMutableArray<GANMyWorkerDataModel *> *arrMyWorkers;
@property (strong, nonatomic) NSMutableArray<GANUserCompanyDataModel *> *arrCompanyUsers;

@property (assign, atomic) BOOL isMyWorkersLoading;

+ (instancetype) sharedInstance;
- (void) initializeManager;

+ (NSString *) generateCompanyCodeFromName: (NSString *) companyName;

#pragma mark - Requests

- (void) requestCreateCompany: (GANCompanyDataModel *) company Callback: (void (^) (int status, GANCompanyDataModel *companyNew)) callback;

- (void) requestGetMyWorkersListWithCallback: (void (^) (int status)) callback;
- (void) requestAddMyWorkerWithUserIds: (NSArray *) arrUserIds Callback: (void (^) (int status)) callback;
- (void) requestSearchNewWorkersByPhoneNumber: (NSString *) phoneNumber Callback: (void (^) (int status, NSArray *arrWorkers)) callback;
- (void) requestSendInvite: (GANPhoneDataModel *) phone CompanyId: (NSString *) companyId Callback: (void (^) (int status)) callback;

#pragma mark - Company Users

- (void) requestGetCompanyUsersWithCallback: (void (^) (int status)) callback;
- (void) requestUpdateCompanyUserType: (NSString *) userId Type: (GANENUM_USER_TYPE) type Callback: (void (^) (int status)) callback;

@end
