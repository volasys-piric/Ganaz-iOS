//
//  GANLocationDataModel.m
//  Ganaz
//
//  Created by Piric Djordje on 6/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANLocationDataModel.h"
#import "GANGenericFunctionManager.h"

@implementation GANLocationDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.fLatitude = 0;
    self.fLongitude = 0;
    self.szAddress = @"";
}

- (void) initializeWithLocation: (GANLocationDataModel *) location{
    self.fLatitude = location.fLatitude;
    self.fLongitude = location.fLongitude;
    self.szAddress = location.szAddress;
}

- (void) setWithDictionary:(NSDictionary *)dict{
    [self initialize];
    NSArray *loc = [dict objectForKey:@"loc"];
    self.fLatitude = [GANGenericFunctionManager refineFloat:[loc objectAtIndex:1] DefaultValue:0];
    self.fLongitude = [GANGenericFunctionManager refineFloat:[loc objectAtIndex:0] DefaultValue:0];
    self.szAddress = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"address"]];
}

- (NSDictionary *) serializeToDictionary{
    return @{@"lat": [NSString stringWithFormat:@"%.6f", self.fLatitude],
             @"lng": [NSString stringWithFormat:@"%.6f", self.fLongitude],
             @"address": self.szAddress,
             };
}

- (CLLocation *) generateCLLocation{
    return [[CLLocation alloc] initWithLatitude:self.fLatitude longitude:self.fLongitude];
}

@end
