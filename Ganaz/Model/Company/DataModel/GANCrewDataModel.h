//
//  GANCrewDataModel.h
//  Ganaz
//
//  Created by Chris Lin on 11/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GANCrewDataModel : NSObject

@property (strong, nonatomic) NSString *szId;
@property (strong, nonatomic) NSString *szCompanyId;
@property (strong, nonatomic) NSString *szTitle;

- (instancetype) init;
- (void) setWithDictionary: (NSDictionary *) dict;

@end
