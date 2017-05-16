//
//  GANRecruitManager.h
//  Ganaz
//
//  Created by Piric Djordje on 3/23/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANRecruitDataModel.h"

@interface GANRecruitManager : NSObject

@property (strong, nonatomic) NSMutableArray *arrRecruits;

+ (instancetype) sharedInstance;
- (void) initializeManager;

#pragma mark - Request

- (void) requestSubmitRecruit: (GANRecruitRequestDataModel *) recruitRequest Callback: (void (^) (int status, int count)) callback;

@end
