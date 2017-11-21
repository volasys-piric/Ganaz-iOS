//
//  GANUserWorkerDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 3/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANUserBaseDataModel.h"

@interface GANUserWorkerDataModel : GANUserBaseDataModel

@property (strong, nonatomic) GANLocationDataModel *modelLocation;
@property (assign, atomic) BOOL isNewJobLock;

@property (assign, atomic) BOOL isJobSearchLock;
@property (strong, nonatomic) NSMutableArray <NSString *> *arrayJobSearchAllowedCompanyIds;

- (instancetype) init;
- (void) setWithDictionary: (NSDictionary *) dict;

@end
