//
//  GANMembershipPlanDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 5/23/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANUtils.h"

@interface GANMembershipPlanDataModel : NSObject

@property (strong, nonatomic) NSString *szId;
@property (assign, atomic) GANENUM_MEMBERSHIPPLAN_TYPE type;
@property (strong, nonatomic) NSString *szTitle;
@property (assign, atomic) float fFee;
@property (assign, atomic) int nJobs;
@property (assign, atomic) int nRecruits;
@property (assign, atomic) int nMessages;

- (instancetype) init;
- (void) setWithDictionary: (NSDictionary *) dict;

@end
