//
//  GANMyWorkerDataModel.m
//  Ganaz
//
//  Created by Piric Djordje on 3/15/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANMyWorkerDataModel.h"
#import "GANLocationManager.h"
#import "GANGenericFunctionManager.h"

@implementation GANMyWorkerDataModel

- (instancetype) init{
    self = [super init];
    if (self){
//        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szWorkerUserId = @"";
    self.szCompanyUserId = @"";
    self.szId = @"";
    self.szAccessToken = @"";
    self.szFirstName = @"";
    self.szLastName = @"";
    self.szUserName = @"";
    self.szPassword = @"";
    self.szEmail = @"";
    self.enumType = GANENUM_USER_TYPE_WORKER;
    self.modelPhone = [[GANPhoneDataModel alloc] init];
    self.enumAuthType = GANENUM_USER_AUTHTYPE_EMAIL;
    self.szExternalId = @"";
    self.szPlayerId = @"";
    
    self.modelLocation = [[GANLocationDataModel alloc] init];
    
    GANLocationManager *managerLocation = [GANLocationManager sharedInstance];
    if (managerLocation.location != nil){
        self.modelLocation.fLatitude = managerLocation.location.coordinate.latitude;
        self.modelLocation.fLongitude = managerLocation.location.coordinate.longitude;
        self.modelLocation.szAddress = managerLocation.szAddress;
    }
}

- (void) setWithDictionary:(NSDictionary *)dict{
    [super setWithDictionary:dict];
    
    self.szWorkerUserId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"worker_user_id"]];
    self.szCompanyUserId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"company_user_id"]];
}

- (NSDictionary *) serializeToDictionary{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super serializeToDictionary]];
    [dict setObject:self.szWorkerUserId forKey:@"worker_user_id"];
    [dict setObject:self.szCompanyUserId forKey:@"company_user_id"];
    return dict;
}

@end
