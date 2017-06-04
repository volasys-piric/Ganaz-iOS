//
//  GANPhoneDataModel.h
//  Ganaz
//
//  Created by Chris Lin on 6/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GANPhoneDataModel : NSObject

@property (strong, nonatomic) NSString *szCountry;
@property (strong, nonatomic) NSString *szCountryCode;
@property (strong, nonatomic) NSString *szLocalNumber;

- (void) setWithDictionary:(NSDictionary *)dict;
- (NSDictionary *) serializeToDictionary;
- (NSString *) getBeautifiedPhoneNumber;

@end

