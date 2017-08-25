//
//  GANUserMinimumInfoDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 7/14/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANUtils.h"

@interface GANUserMinimumInfoDataModel : NSObject

@property (strong, nonatomic) NSString *szUserName;
@property (strong, nonatomic) NSString *szPassword;
@property (strong, nonatomic) GANPhoneDataModel *modelPhone;
@property (assign, atomic) GANENUM_USER_AUTHTYPE enumAuthType;
@property (assign, atomic) GANENUM_USER_TYPE enumUserType;

- (instancetype) init;
- (void) setWithDictionary:(NSDictionary *)dict;
- (NSDictionary *) serializeToDictionary;

@end
