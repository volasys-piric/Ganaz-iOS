//
//  GANPhoneDataModel.m
//  Ganaz
//
//  Created by Piric Djordje on 6/3/17.
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

- (void) initializeWithPhone: (GANPhoneDataModel *) phone{
    self.szCountry = phone.szCountry;
    self.szCountryCode = phone.szCountryCode;
    self.szLocalNumber = phone.szLocalNumber;
}

- (NSDictionary *) serializeToDictionary{
    return @{@"country": self.szCountry,
             @"country_code": self.szCountryCode,
             @"local_number": self.szLocalNumber,
             };
}

- (void) setLocalNumber: (NSString *) localNumber{
    self.szLocalNumber = [GANGenericFunctionManager stripNonnumericsFromNSString:localNumber];
    if (self.szLocalNumber.length > 10){
        self.szLocalNumber = [self.szLocalNumber substringFromIndex:(self.szLocalNumber.length - 10)];
    }
}

- (NSString *) getBeautifiedPhoneNumber{
    return [GANGenericFunctionManager beautifyPhoneNumber:self.szLocalNumber CountryCode:self.szCountryCode];
}

- (BOOL) isSamePhoneNumber: (NSString *) phoneNumber {
    phoneNumber = [GANGenericFunctionManager refineNSString:phoneNumber];
    if (phoneNumber.length > 10) phoneNumber = [phoneNumber substringFromIndex:1];
    if ([self.szLocalNumber isEqualToString:phoneNumber] == YES) {
        return YES;
    }
    return NO;
}

@end

