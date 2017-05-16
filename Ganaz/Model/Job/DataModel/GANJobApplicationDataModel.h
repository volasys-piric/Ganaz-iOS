//
//  GANJobApplicationDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 3/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GANJobApplicationDataModel : NSObject

@property (strong, nonatomic) NSString *szId;
@property (strong, nonatomic) NSString *szJobId;
@property (strong, nonatomic) NSString *szWorkerUserId;

- (instancetype) init;
- (void) setWithDictionary: (NSDictionary *) dict;

@end
