//
//  GANMyCompaniesManager.h
//  Ganaz
//
//  Created by Piric Djordje on 3/17/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GANMyCompaniesManager : NSObject

@property (strong, nonatomic) NSMutableArray *arrCompaniesFound;

+ (instancetype) sharedInstance;
- (void) initializeManager;

- (void) getCompanyBusinessNameByCompanyUserId: (NSString *) companyUserId Callback: (void (^) (NSString *businessName)) callback;

#pragma mark - Requests

- (void) requestGetCompanyDetailsByCompanyUserId: (NSString *) companyUserId Callback: (void (^) (int index)) callback;

@end
