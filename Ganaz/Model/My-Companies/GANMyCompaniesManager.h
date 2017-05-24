//
//  GANMyCompaniesManager.h
//  Ganaz
//
//  Created by Piric Djordje on 3/17/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANCompanyDataModel.h"

@interface GANMyCompaniesManager : NSObject

@property (strong, nonatomic) NSMutableArray<GANCompanyDataModel *> *arrCompaniesFound;

+ (instancetype) sharedInstance;
- (void) initializeManager;

- (void) getCompanyBusinessNameByCompanyUserId: (NSString *) companyUserId Callback: (void (^) (NSString *businessName)) callback;

#pragma mark - Requests

- (void) requestGetCompanyDetailsByCompanyUserId: (NSString *) companyUserId Callback: (void (^) (int index)) callback;

@end
