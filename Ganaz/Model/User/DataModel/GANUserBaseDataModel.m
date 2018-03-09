//
//  GANUserBaseDataModel.m
//  Ganaz
//
//  Created by Piric Djordje on 3/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANUserBaseDataModel.h"
#import "GANUserWorkerDataModel.h"
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
    self.enumType = [GANUtils getUserTypeFromString:[GANGenericFunctionManager refineNSString:[dict objectForKey:@"type"]]];
    self.szAccessToken = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"access_token"]];
    self.szFirstName = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"firstname"]];
    self.szLastName = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"lastname"]];
    self.szUserName = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"username"]];
    self.szEmail = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"email_address"]];
    self.szExternalId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"external_id"]];
    self.dateCreatedAt = [GANGenericFunctionManager getDateTimeFromNormalizedString:[dict objectForKey:@"created_at"]];
    
    NSArray *arrPlayerIds = [dict objectForKey:@"player_ids"];
    self.arrPlayerIds = [[NSMutableArray alloc] init];
    for (int i = 0; i < (int) [arrPlayerIds count]; i++){
        [self.arrPlayerIds addObject:[GANGenericFunctionManager refineNSString:[arrPlayerIds objectAtIndex:i]]];
    }
    
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
             @"player_ids": self.arrPlayerIds,
             };
}

- (int) getIndexForPlayerId: (NSString *) playerId{
    for (int i = 0; i < (int) [self.arrPlayerIds count]; i++){
        NSString *sz = [self.arrPlayerIds objectAtIndex:i];
        if ([sz isEqualToString:playerId] == YES){
            return i;
        }
    }
    return -1;
}

- (void) addPlayerIdIfNeeded: (NSString *) playerId{
    if (playerId.length == 0) return;
    if ([self getIndexForPlayerId:playerId] != -1) return;
    [self.arrPlayerIds addObject:playerId];
}

- (NSString *) getFullName{
    return [NSString stringWithFormat:@"%@ %@", self.szFirstName, self.szLastName];
}

- (NSString *) getValidUsername{
    if (self.enumType == GANENUM_USER_TYPE_COMPANY_ADMIN || self.enumType == GANENUM_USER_TYPE_COMPANY_REGULAR){
        return [self getFullName];
    }
    else if (self.enumType == GANENUM_USER_TYPE_WORKER || self.enumType == GANENUM_USER_TYPE_ONBOARDING_WORKER){
        return [self.modelPhone getBeautifiedPhoneNumber];
    }
    else if (self.enumType == GANENUM_USER_TYPE_FACEBOOK_LEAD_WORKER) {
        return [NSString stringWithFormat:@"Candidate #%d", ((GANUserWorkerDataModel *) self).indexForCandidate];
    }
    return @"";
}

- (GANUserRefDataModel *) toUserRefObject {
    GANUserRefDataModel *userRef = [[GANUserRefDataModel alloc] init];
    userRef.szUserId = self.szId;
    userRef.szCompanyId = @"";
    return userRef;
}

@end
