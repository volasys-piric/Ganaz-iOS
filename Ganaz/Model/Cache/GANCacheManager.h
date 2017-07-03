//
//  GANCacheManager.h
//  Ganaz
//
//  Created by Piric Djordje on 5/28/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANUserManager.h"

@interface GANCacheManager : NSObject

@property (strong, nonatomic) NSMutableArray<GANUserBaseDataModel *> *arrUsers;
@property (strong, nonatomic) NSMutableArray<GANCompanyDataModel *> *arrCompanies;

+ (instancetype) sharedInstance;
- (void) initializeManager;

#pragma mark Users

- (int) getIndexForUserWithUserId: (NSString *) userId;
- (int) addUserIfNeeded: (GANUserBaseDataModel *) userNew;
- (void) requestGetIndexForUserByUserId: (NSString *) userId Callback: (void (^) (int index)) callback;

#pragma mark - Company

- (int) addCompanyIfNeeded: (GANCompanyDataModel *) company;
- (int) getIndexForCompanyByCompanyId: (NSString *) companyId;
- (int) getIndexForCompanyByCompanyCode: (NSString *) companyCode;
- (void) getCompanyBusinessNameESByCompanyId: (NSString *) companyId Callback: (void (^) (NSString *businessNameES)) callback;
- (void) requestGetCompanyDetailsByCompanyId: (NSString *) companyId Callback: (void (^) (int indexCompany)) callback;
- (void) requestGetCompanyDetailsByCompanyCode: (NSString *) companyCode Callback: (void (^) (int indexCompany)) callback;

@end
