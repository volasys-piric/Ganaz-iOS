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
#import "GANCrewDataModel.h"

@interface GANCompanyManager : NSObject

@property (strong, nonatomic) NSMutableArray<GANCrewDataModel *> *arrayCrews;
@property (strong, nonatomic) NSMutableArray<GANMyWorkerDataModel *> *arrMyWorkers;
@property (strong, nonatomic) NSMutableArray<GANUserCompanyDataModel *> *arrCompanyUsers;

@property (assign, atomic) BOOL isMyWorkersLoading;

+ (instancetype) sharedInstance;
- (void) initializeManager;

+ (NSString *) generateCompanyCodeFromName: (NSString *) companyName;
- (void) getBestUserDisplayNameWithUserId: (NSString *) userId Callback: (void (^) (NSString *displayName)) callback;
- (int) getIndexForMyWorkersWithUserId: (NSString *) userId;
- (NSArray <GANMyWorkerDataModel *> *) getMembersListForCrew: (NSString *) crewId;
- (NSArray <GANMyWorkerDataModel *> *) getNonCrewMembersList;

- (BOOL) checkUserInMyworkerList:(NSString *) szPhoneNumber;

#pragma mark - Requests

- (void) requestCreateCompany: (GANCompanyDataModel *) company Callback: (void (^) (int status, GANCompanyDataModel *companyNew)) callback;

#pragma mark - Crews

- (void) requestGetCrewsListWithCallback: (void (^) (int status)) callback;
- (void) requestAddCrewWithTitle: (NSString *) title Callback: (void (^) (int status)) callback;
- (void) requestUpdateCrewWithCrewId: (NSString *) crewId Title: (NSString *) title Callback: (void (^) (int status)) callback;
- (void) requestDeleteCrewWithCrewid: (NSString *) crewId Callback: (void (^) (int status)) callback;

#pragma mark - My Workers

- (void) requestGetMyWorkersListWithCallback: (void (^) (int status)) callback;
- (void) requestAddMyWorkerWithUserIds: (NSArray *) arrUserIds Callback: (void (^) (int status)) callback;
- (void) requestUpdateMyWorkerNicknameWithMyWorkerId: (NSString *) myWorkerId Nickname: (NSString *) nickname Callback: (void (^) (int status)) callback;
- (void) requestUpdateMyWorkerCrewWithMyWorkerId: (NSString *) myWorkerId CrewId: (NSString *) crewId Callback: (void (^) (int status)) callback;

- (void) requestSearchNewWorkersByPhoneNumber: (NSString *) phoneNumber Callback: (void (^) (int status, NSArray *arrWorkers)) callback;
- (void) requestSendInvite: (GANPhoneDataModel *) phone CompanyId: (NSString *) companyId inviteOnly:(BOOL)bInviteOnly Callback: (void (^) (int status)) callback;

#pragma mark - Company Users

- (void) requestGetCompanyUsersWithCallback: (void (^) (int status)) callback;
- (void) requestUpdateCompanyUserType: (NSString *) userId Type: (GANENUM_USER_TYPE) type Callback: (void (^) (int status)) callback;

@end
