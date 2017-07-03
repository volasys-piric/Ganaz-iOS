//
//  GANDataManager.h
//  Ganaz
//
//  Created by Piric Djordje on 6/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANBenefitDataModel.h"

@interface GANDataManager : NSObject

@property (strong, nonatomic) NSMutableArray<GANBenefitDataModel *> *arrBenefits;

+ (instancetype) sharedInstance;

#pragma mark - Load from plist

- (void) loadBenefits;

#pragma mark - Utils

- (int) getIndexForBenefitsByName: (NSString *) name;

@end
