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

- (instancetype) initWithCountry: (int) country LocalNumber: (NSString *) localNumber {
    self = [super init];
    if (self){
        [self setCountry:country];
        [self setLocalNumber:localNumber];
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

- (void) setCountry: (int) country{
    if (country == GANENUM_PHONE_COUNTRY_US) {
        self.szCountry = @"US";
        self.szCountryCode = @"1";
    }
    else if (country == GANENUM_PHONE_COUNTRY_MX) {
        self.szCountry = @"MX";
        self.szCountryCode = @"52";
    }
}

- (int) getCountry {
    return [GANUtils getCountryFromString:self.szCountry];
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

- (NSString *) getNormalizedPhoneNumber{
    GANENUM_PHONE_COUNTRY country = [GANUtils getCountryFromString:self.szCountry];
    if (country == GANENUM_PHONE_COUNTRY_US) return self.szLocalNumber;
    
    return [NSString stringWithFormat:@"%@%@", self.szCountryCode, self.szLocalNumber];
}

- (BOOL) isSamePhone: (GANPhoneDataModel *) phone{
    NSString *phoneNumber = [GANGenericFunctionManager refineNSString:phone.szLocalNumber];
    if (phoneNumber.length > 10) phoneNumber = [phoneNumber substringFromIndex:1];
    
    if ([self.szLocalNumber isEqualToString:phoneNumber] == YES && [self.szCountryCode isEqualToString:phone.szCountryCode] == YES) {
        return YES;
    }
    return NO;
}

@end

