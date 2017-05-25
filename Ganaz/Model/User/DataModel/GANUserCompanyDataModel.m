//
//  GANUserCompanyDataModel.m
//  Ganaz
//
//  Created by Piric Djordje on 3/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANUserCompanyDataModel.h"
#import "GANGenericFunctionManager.h"
#import "GANJobManager.h"
#import "Global.h"

@implementation GANUserCompanyDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szId = @"";
    self.szAccessToken = @"";
    self.szFirstName = @"";
    self.szLastName = @"";
    self.szUserName = @"";
    self.szPassword = @"";
    self.szEmail = @"";
    self.enumType = GANENUM_USER_TYPE_COMPANY_ADMIN;
    self.modelPhone = [[GANPhoneDataModel alloc] init];
    self.enumAuthType = GANENUM_USER_AUTHTYPE_EMAIL;
    self.szExternalId = @"";
    self.szPlayerId = @"";
    
    self.szCompanyId = @"";
    self.modelCompany = [[GANCompanyDataModel alloc] init];
}

- (void) setWithDictionary:(NSDictionary *)dict{
    [super setWithDictionary:dict];
    
    NSDictionary *dictCompany = [dict objectForKey:@"company"];
    NSDictionary *dictAccount = [dictCompany objectForKey:@"account"];
    
    self.szCompanyId = [GANGenericFunctionManager refineNSString:[dictCompany objectForKey:@"company_id"]];
    [self.modelCompany setWithDictionary:dictAccount];
}

- (NSDictionary *) serializeToDictionary{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super serializeToDictionary]];
    [dict setObject:@{@"company_id": self.szCompanyId,
                      }
             forKey:@"company"];
    return dict;
}

@end
