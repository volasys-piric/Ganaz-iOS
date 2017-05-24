//
//  GANCompanyManager.h
//  Ganaz
//
//  Created by Piric Djordje on 5/24/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANCompanyDataModel.h"

@interface GANCompanyManager : NSObject

@property (strong, nonatomic) NSMutableArray<GANCompanyDataModel *> *arrCompaniesFound;

+ (instancetype) sharedInstance;
- (void) initializeManager;

+ (NSString *) generateCompanyCodeFromName: (NSString *) companyName;
- (void) getCompanyBusinessNameESByCompanyId: (NSString *) companyId Callback: (void (^) (NSString *businessNameES)) callback;

#pragma mark - Requests

- (void) requestCreateCompany: (GANCompanyDataModel *) company Callback: (void (^) (int status, GANCompanyDataModel *companyNew)) callback;

- (void) requestGetCompanyDetailsByCompanyId: (NSString *) companyId Callback: (void (^) (int indexCompany)) callback;

@end
