//
//  GANPhoneDataModel.m
//  Ganaz
//
//  Created by Chris Lin on 6/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANPhoneDataModel.h"
#import "GANGenericFunctionManager.h"

@implementation GANPhoneDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szCountry = @"US";
    self.szCountryCode = @"1";
    self.szLocalNumber = @"";
}

- (void) setWithDictionary:(NSDictionary *)dict{
    [self initialize];
    self.szCountry = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"country"]];
    self.szCountryCode = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"country_code"]];
    self.szLocalNumber = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"local_number"]];
}

- (NSDictionary *) serializeToDictionary{
    return @{@"country": self.szCountry,
             @"country_code": self.szCountryCode,
             @"local_number": self.szLocalNumber,
             };
}

- (NSString *) getBeautifiedPhoneNumber{
    return [GANGenericFunctionManager beautifyPhoneNumber:self.szLocalNumber CountryCode:self.szCountryCode];
}

@end

