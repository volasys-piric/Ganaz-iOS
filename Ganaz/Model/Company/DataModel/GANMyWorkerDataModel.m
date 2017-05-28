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
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szId = @"";
    self.szWorkerUserId = @"";
    self.szCompanyId = @"";
    self.szCrewId = @"";
    self.modelWorker = [[GANUserWorkerDataModel alloc] init];
}

- (void) setWithDictionary:(NSDictionary *)dict{
    self.szId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"_id"]];
    self.szWorkerUserId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"worker_user_id"]];
    self.szCompanyId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"company_id"]];
    self.szCrewId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"crew_id"]];
    
    NSDictionary *dictWorker = [dict objectForKey:@"worker_account"];
    [self.modelWorker setWithDictionary:dictWorker];
}

- (NSDictionary *) serializeToDictionary{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.szCompanyId forKey:@"company_id"];
    [dict setObject:self.szWorkerUserId forKey:@"worker_user_id"];
    [dict setObject:self.szCrewId forKey:@"crew_id"];
    return dict;
}

@end
