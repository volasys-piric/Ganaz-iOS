//
//  GANUserCompanyDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 3/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANUserBaseDataModel.h"
#import "GANCompanyDataModel.h"

@interface GANUserCompanyDataModel : GANUserBaseDataModel

@property (strong, nonatomic) NSString *szCompanyId;
@property (strong, nonatomic) GANCompanyDataModel *modelCompany;

- (instancetype) init;
- (void) setWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) serializeToDictionary;

@end
