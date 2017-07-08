//
//  GANAddressDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 6/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GANAddressDataModel : NSObject

@property (strong, nonatomic) NSString *szAddress1;
@property (strong, nonatomic) NSString *szAddress2;
@property (strong, nonatomic) NSString *szCity;
@property (strong, nonatomic) NSString *szState;
@property (strong, nonatomic) NSString *szCountry;

- (void) setWithDictionary:(NSDictionary *)dict;
- (NSDictionary *) serializeToDictionary;

@end
