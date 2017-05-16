//
//  GANMyWorkerDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 3/15/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANUserWorkerDataModel.h"

@interface GANMyWorkerDataModel : GANUserWorkerDataModel

@property (strong, nonatomic) NSString *szWorkerUserId;
@property (strong, nonatomic) NSString *szCompanyUserId;

- (instancetype) init;
- (void) setWithDictionary: (NSDictionary *) dict;

@end
