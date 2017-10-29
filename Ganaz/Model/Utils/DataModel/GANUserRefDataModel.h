//
//  GANUserRefDataModel.h
//  Ganaz
//
//  Created by Chris Lin on 10/5/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GANUserRefDataModel : NSObject

@property (strong, nonatomic) NSString *szCompanyId;
@property (strong, nonatomic) NSString *szUserId;

- (void) setWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) serializeToDictionary;
- (BOOL) isSameUser: (GANUserRefDataModel *) user;

@end

