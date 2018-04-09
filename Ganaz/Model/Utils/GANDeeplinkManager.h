//
//  GANDeeplinkManager.h
//  Ganaz
//
//  Created by Chris Lin on 12/13/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANUtils.h"

@interface GANDeeplinkManager : NSObject

@property (assign, atomic) GANENUM_BRANCHDEEPLINK_ACTION enumAction;
@property (strong, nonatomic) GANPhoneDataModel *modelPhone;

+ (instancetype) sharedInstance;
- (void) initializeManager;

- (void) analyzeBranchDeeplink: (NSDictionary *) params;

@end
