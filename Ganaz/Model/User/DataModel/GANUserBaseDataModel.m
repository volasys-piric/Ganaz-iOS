//
//  GANUserBaseDataModel.m
//  Ganaz
//
//  Created by Piric Djordje on 3/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANUserBaseDataModel.h"
#import "GANGenericFunctionManager.h"

@implementation GANUserBaseDataModel

- (instancetype) init{
    self = [super init];
    if (self){
    }
    return self;
}

- (void) setWithDictionary:(NSDictionary *)dict{
    self.szId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"_id"]];
    self.szAccessToken = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"access_token"]];
    self.szFirstName = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"firstname"]];
    self.szLastName = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"lastname"]];
    self.szUserName = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"username"]];
    self.szEmail = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"email_address"]];
    self.szExternalId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"external_id"]];
    self.szPlayerId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"player_id"]];
    
    NSDictionary *dictPhone = [dict objectForKey:@"phone_number"];
    self.modelPhone = [[GANPhoneDataModel alloc] init];
    [self.modelPhone setWithDictionary:dictPhone];
    self.enumAuthType = [GANUtils getUserAuthTypeFromString:[GANGenericFunctionManager refineNSString:[dict objectForKey:@"auth_type"]]];
}

- (NSDictionary *) serializeToDictionary{
    return @{@"username": self.szUserName,
             @"password": self.szPassword,
             @"firstname": self.szFirstName,
             @"lastname": self.szLastName,
             @"phone_number": [self.modelPhone serializeToDictionary],
             @"email_address": self.szEmail,
             @"type": [GANUtils getStringFromUserType:self.enumType],
             @"auth_type": [GANUtils getStringFromUserAuthType:self.enumAuthType],
             @"external_id": self.szExternalId,
             @"player_id": self.szPlayerId,
             };
}

@end
