//
//  GANUserMinimumInfoDataModel.m
//  Ganaz
//
//  Created by Piric Djordje on 7/14/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANUserMinimumInfoDataModel.h"
#import "GANGenericFunctionManager.h"

@implementation GANUserMinimumInfoDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        self.szUserName = @"";
        self.szPassword = @"";
        self.modelPhone = [[GANPhoneDataModel alloc] init];
        self.enumAuthType = GANENUM_USER_AUTHTYPE_PHONE;
        self.enumUserType = GANENUM_USER_TYPE_WORKER;
    }
    return self;
}

- (void) setWithDictionary:(NSDictionary *)dict{
    self.szUserName = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"username"]];
    self.szPassword = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"password"]];

    NSString *szAuthType = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"auth_type"]];
    if (szAuthType.length > 0 && [GANUtils getUserAuthTypeFromString:szAuthType] == GANENUM_USER_AUTHTYPE_PHONE){
        [self.modelPhone setWithDictionary:[dict objectForKey:@"phone_number"]];
        self.enumAuthType = GANENUM_USER_AUTHTYPE_PHONE;
    }
    else if (szAuthType.length > 0){
        self.enumAuthType = [GANUtils getUserAuthTypeFromString:szAuthType];
    }
    else {
        // old version (v1.2-)
        self.enumAuthType = GANENUM_USER_AUTHTYPE_EMAIL;
    }
    
    self.enumUserType = [GANGenericFunctionManager refineInt:[dict objectForKey:@"user_type"] DefaultValue:GANENUM_USER_TYPE_WORKER];
}

- (NSDictionary *) serializeToDictionary{
    return @{@"username": self.szUserName,
             @"password": self.szPassword,
             @"phone_number": [self.modelPhone serializeToDictionary],
             @"auth_type": [GANUtils getStringFromUserAuthType:self.enumAuthType],
             @"user_type": @(self.enumUserType),
             };
}

@end
