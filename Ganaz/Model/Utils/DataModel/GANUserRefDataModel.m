//
//  GANUserRefDataModel.m
//  Ganaz
//
//  Created by Chris Lin on 10/5/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANUserRefDataModel.h"
#import "GANGenericFunctionManager.h"

@implementation GANUserRefDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szCompanyId = @"";
    self.szUserId = @"";
}

- (void) setWithDictionary:(NSDictionary *)dict{
    [self initialize];
    if (dict == nil || [dict isKindOfClass:[NSDictionary class]] == NO) return;
    
    self.szCompanyId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"company_id"]];
    self.szUserId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"user_id"]];
}

- (NSDictionary *) serializeToDictionary{
    return @{@"company_id": self.szCompanyId,
             @"user_id": self.szUserId,
             };
}

- (BOOL) isWorker{
    if (self.szCompanyId.length == 0 && self.szUserId.length > 0) return YES;
    return NO;
}

- (BOOL) isCompanyUser{
    if (self.szCompanyId.length > 0 && self.szUserId.length > 0) return YES;
    return NO;
}

- (BOOL) isValidUser{
    if (self.szCompanyId.length == 0 && self.szUserId.length == 0) return NO;
    return YES;
}

- (BOOL) isSameUser: (GANUserRefDataModel *) user{
    if ((self.szCompanyId.length == 0 && user.szCompanyId.length == 0) &&
        ([self.szUserId isEqualToString:user.szUserId] == YES)) {
        // Exactly same user
        return YES;
    }
    
    if ((self.szCompanyId.length > 0 && user.szCompanyId.length > 0) &&
        ([self.szCompanyId isEqualToString:user.szCompanyId] == YES)) {
        // Same company
        return YES;
    }
    return NO;
}

@end
