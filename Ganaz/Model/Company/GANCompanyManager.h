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

+ (instancetype) sharedInstance;
- (void) initializeManager;

+ (NSString *) generateCompanyCodeFromName: (NSString *) companyName;

- (void) requestCreateCompany: (GANCompanyDataModel *) company Callback: (void (^) (int status, GANCompanyDataModel *companyNew)) callback;

@end
