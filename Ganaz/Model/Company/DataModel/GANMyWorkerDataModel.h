//
//  GANMyWorkerDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 3/15/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANUserWorkerDataModel.h"

@interface GANMyWorkerDataModel: NSObject

@property (strong, nonatomic) NSString *szId;
@property (strong, nonatomic) NSString *szWorkerUserId;
@property (strong, nonatomic) NSString *szCompanyId;
@property (strong, nonatomic) NSString *szNickname;
@property (strong, nonatomic) NSString *szCrewId;
@property (strong, nonatomic) GANUserWorkerDataModel *modelWorker;

- (instancetype) init;
- (void) setWithDictionary: (NSDictionary *) dict;
- (NSString *) getDisplayName;

@end
