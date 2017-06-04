//
//  GANBenefitDataModel.m
//  Ganaz
//
//  Created by Chris Lin on 6/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANBenefitDataModel.h"
#import "GANGenericFunctionManager.h"

@implementation GANBenefitDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szName = @"";
    self.szIcon = @"";
    self.modelTitle = [[GANTransContentsDataModel alloc] init];
    self.modelDescription = [[GANTransContentsDataModel alloc] init];
}

- (void) setWithDictionary:(NSDictionary *)dict{
    [self initialize];
    self.szName = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"name"]];
    self.szIcon = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"icon"]];
    [self.modelTitle setWithDictionary:[dict objectForKey:@"title"]];
    [self.modelDescription setWithDictionary:[dict objectForKey:@"description"]];
}

- (NSString *) getTitleEN{
    return [self.modelTitle getTextEN];
}

- (NSString *) getTitleES{
    return [self.modelTitle getTextES];
}

- (NSString *) getDescriptionEN{
    return [self.modelDescription getTextEN];
}

- (NSString *) getDescriptionES{
    return [self.modelDescription getTextES];
}

@end
