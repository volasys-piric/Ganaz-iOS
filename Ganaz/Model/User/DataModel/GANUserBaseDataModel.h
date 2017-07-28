//
//  GANUserBaseDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 3/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANUtils.h"

@interface GANUserBaseDataModel : NSObject

@property (strong, nonatomic) NSString *szId;
@property (strong, nonatomic) NSString *szAccessToken;
@property (strong, nonatomic) NSString *szFirstName;
@property (strong, nonatomic) NSString *szLastName;
@property (strong, nonatomic) NSString *szUserName;
@property (strong, nonatomic) NSString *szPassword;
@property (strong, nonatomic) NSString *szEmail;
@property (assign, atomic) GANENUM_USER_TYPE enumType;
@property (strong, nonatomic) GANPhoneDataModel *modelPhone;
@property (assign, atomic) GANENUM_USER_AUTHTYPE enumAuthType;
@property (strong, nonatomic) NSString *szExternalId;
@property (strong, nonatomic) NSMutableArray *arrPlayerIds;

- (instancetype) init;
- (void) setWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) serializeToDictionary;

- (int) getIndexForPlayerId: (NSString *) playerId;
- (void) addPlayerIdIfNeeded: (NSString *) playerId;

- (NSString *) getFullName;
- (NSString *) getValidUsername;

@end
