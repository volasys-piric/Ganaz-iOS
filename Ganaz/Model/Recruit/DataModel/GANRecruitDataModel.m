//
//  GANRecruitDataModel.m
//  Ganaz
//
//  Created by Piric Djordje on 3/23/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANRecruitDataModel.h"
#import "GANGenericFunctionManager.h"

@implementation GANRecruitRequestDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.arrJobIds = [[NSMutableArray alloc] init];
    self.arrReRecruitUserIds = [[NSMutableArray alloc] init];
    self.fBroadcast = -1;
}

- (void) setWithDictionary:(NSDictionary *)dict{
    [self initialize];
    
    NSArray *arrJobIds = [dict objectForKey:@"job_ids"];
    NSArray *arrReRecruitUserIds = [dict objectForKey:@"re_recruit_user_ids"];
    self.fBroadcast = [GANGenericFunctionManager refineFloat:[dict objectForKey:@"broadcast"] DefaultValue:-1];
    
    if (arrJobIds != nil && [arrJobIds isKindOfClass:[NSArray class]] == YES){
        for (int i = 0; i < (int) [arrJobIds count]; i++){
            [self.arrJobIds addObject: [GANGenericFunctionManager refineNSString:[arrJobIds objectAtIndex:i]]];
        }
    }
    if (arrReRecruitUserIds != nil && [arrReRecruitUserIds isKindOfClass:[NSArray class]] == YES){
        for (int i = 0; i < (int) [arrReRecruitUserIds count]; i++){
            [self.arrReRecruitUserIds addObject: [GANGenericFunctionManager refineNSString:[arrReRecruitUserIds objectAtIndex:i]]];
        }
    }
}

- (NSDictionary *)serializeToDictionary{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.arrJobIds forKey:@"job_ids"];
    if (self.fBroadcast > 0){
        [dict setObject:[NSString stringWithFormat:@"%.02f", self.fBroadcast] forKey:@"broadcast"];
    }
    if ([self.arrReRecruitUserIds count] > 0){
        [dict setObject:self.arrReRecruitUserIds forKey:@"re_recruit_user_ids"];
    }
    return dict;
}

@end

@implementation GANRecruitDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szId = @"";
    self.modelRequest = [[GANRecruitRequestDataModel alloc] init];
    self.arrReceivedUserIds = [[NSMutableArray alloc] init];
}

- (void) setWithDictionary:(NSDictionary *)dict{
    [self initialize];
    
    self.szId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"_id"]];
    NSDictionary *dictRequest = [dict objectForKey:@"request"];
    [self.modelRequest setWithDictionary:dictRequest];
 
    NSArray *arrReceivedUserIds = [dict objectForKey:@"received_user_ids"];
    if (arrReceivedUserIds != nil && [arrReceivedUserIds isKindOfClass:[NSArray class]] == YES){
        for (int i = 0; i < (int) [arrReceivedUserIds count]; i++){
            [self.arrReceivedUserIds addObject: [GANGenericFunctionManager refineNSString:[arrReceivedUserIds objectAtIndex:i]]];
        }
    }
}

@end
