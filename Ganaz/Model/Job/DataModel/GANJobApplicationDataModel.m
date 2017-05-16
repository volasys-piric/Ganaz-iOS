//
//  GANJobApplicationDataModel.m
//  Ganaz
//
//  Created by Piric Djordje on 3/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANJobApplicationDataModel.h"
#import "GANGenericFunctionManager.h"

@implementation GANJobApplicationDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szId = @"";
    self.szJobId = @"";
    self.szWorkerUserId = @"";
}

- (void) setWithDictionary:(NSDictionary *)dict{
    self.szId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"_id"]];
    self.szJobId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"job_id"]];
    self.szWorkerUserId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"user_id"]];
}

@end
