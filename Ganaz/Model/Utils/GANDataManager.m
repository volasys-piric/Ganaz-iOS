//
//  GANDataManager.m
//  Ganaz
//
//  Created by Chris Lin on 6/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANDataManager.h"

@implementation GANDataManager

+ (instancetype) sharedInstance{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init{
    if (self = [super init]){
        [self initializeManagers];
    }
    return self;
}

- (void) initializeManagers{
    self.arrBenefits = [[NSMutableArray alloc] init];
}

#pragma mark - Load from plist

- (void) loadBenefits{
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Benefits" ofType:@"plist"];
    NSArray *arr = [[NSMutableArray alloc] initWithContentsOfFile:path];
    [self.arrBenefits removeAllObjects];
    
    for (int i = 0; i < (int) [arr count]; i++){
        NSDictionary *dictBenefit = [arr objectAtIndex:i];
        GANBenefitDataModel *benefit = [[GANBenefitDataModel alloc] init];
        [benefit setWithDictionary:dictBenefit];
        [self.arrBenefits addObject:benefit];
    }
}

#pragma mark - Utils

- (int) getIndexForBenefitsByName: (NSString *) name{
    for (int i = 0; i < (int) [self.arrBenefits count]; i++){
        GANBenefitDataModel *benefit = [self.arrBenefits objectAtIndex:i];
        if ([benefit.szName isEqualToString:name] == YES) return i;
    }
    return -1;
}

@end
