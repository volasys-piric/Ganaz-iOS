//
//  GANPhoneDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 6/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANUtils.h"

@interface GANPhoneDataModel : NSObject

@property (strong, nonatomic) NSString *szCountry;
@property (strong, nonatomic) NSString *szCountryCode;
@property (strong, nonatomic) NSString *szLocalNumber;

- (instancetype) initWithCountry: (int) country LocalNumber: (NSString *) localNumber;

- (void) setWithDictionary:(NSDictionary *)dict;
- (void) initializeWithPhone: (GANPhoneDataModel *) phone;
- (NSDictionary *) serializeToDictionary;

- (void) setCountry: (int) country;
- (int) getCountry;
- (void) setLocalNumber: (NSString *) localNumber;
- (void) setWithNumber: (NSString *) phoneNumber;
- (NSString *) getBeautifiedPhoneNumber;
- (NSString *) getNormalizedPhoneNumber;
- (BOOL) isSamePhone: (GANPhoneDataModel *) phone;

@end

