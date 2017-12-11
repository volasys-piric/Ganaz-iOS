//
//  GANCrewDataModel.m
//  Ganaz
//
//  Created by Chris Lin on 11/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCrewDataModel.h"
#import "GANGenericFunctionManager.h"

@implementation GANCrewDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szId = @"";
    self.szCompanyId = @"";
    self.szTitle = @"";
}

- (void) setWithDictionary:(NSDictionary *)dict{
    self.szId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"_id"]];
    self.szCompanyId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"company_id"]];
    self.szTitle = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"title"]];
}

- (NSDictionary *) serializeToDictionary{
    return @{@"_id": self.szId,
             @"company_id": self.szCompanyId,
             @"title": self.szTitle,
             };
}

@end
