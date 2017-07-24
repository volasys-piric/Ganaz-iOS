//
//  GANAddressDataModel.m
//  Ganaz
//
//  Created by Piric Djordje on 6/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANAddressDataModel.h"
#import "GANGenericFunctionManager.h"

@implementation GANAddressDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szAddress1 = @"";
    self.szAddress2 = @"";
    self.szCity = @"";
    self.szState = @"";
    self.szCountry = @"United States";
    self.szZipcode = @"";
}

- (void) setWithDictionary:(NSDictionary *)dict{
    [self initialize];
    self.szAddress1 = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"address1"]];
    self.szAddress2 = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"address2"]];
    self.szCity = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"city"]];
    self.szState = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"state"]];
    self.szCountry = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"country"]];
    self.szZipcode = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"zipcode"]];
}

- (NSDictionary *) serializeToDictionary{
    return @{@"address1": self.szAddress1,
             @"address2": self.szAddress2,
             @"city": self.szCity,
             @"state": self.szState,
             @"country": self.szCountry,
             @"zipcode": self.szZipcode,
             };
}

@end
