//
//  GANPhoneDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 6/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GANPhoneDataModel : NSObject

@property (strong, nonatomic) NSString *szCountry;
@property (strong, nonatomic) NSString *szCountryCode;
@property (strong, nonatomic) NSString *szLocalNumber;

- (void) setWithDictionary:(NSDictionary *)dict;
- (void) initializeWithPhone: (GANPhoneDataModel *) phone;
- (NSDictionary *) serializeToDictionary;

- (void) setLocalNumber: (NSString *) localNumber;
- (NSString *) getBeautifiedPhoneNumber;
- (BOOL) isSamePhoneNumber: (NSString *) phoneNumber;

@end

