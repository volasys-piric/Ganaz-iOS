//
//  GANMyWorkersManager.h
//  Ganaz
//
//  Created by Piric Djordje on 3/15/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANUtils.h"

@interface GANMyWorkersManager : NSObject

@property (strong, nonatomic) NSMutableArray *arrMyWorkers;
@property (assign, atomic) BOOL isMyWorkersLoading;

@property (strong, nonatomic) NSMutableArray *arrWorkersFound;

+ (instancetype) sharedInstance;
- (void) initializeManager;

#pragma mark - Requests

- (void) requestGetMyWorkersListWithCallback: (void (^) (int status)) callback;
- (void) requestAddMyWorkerWithUserIds: (NSArray *) arrUserIds Callback: (void (^) (int status)) callback;
- (void) requestSearchNewWorkersByPhoneNumber: (NSString *) phoneNumber Callback: (void (^) (int status, NSArray *arrWorkers)) callback;
- (void) requestGetWorkerDetailsByWorkerUserId: (NSString *) workerUserId Callback: (void (^) (int index)) callback;

- (void) requestSendInvite: (GANPhoneDataModel *) phone CompanyUserId: (NSString *) companyUserId Callback: (void (^) (int status)) callback;

@end
