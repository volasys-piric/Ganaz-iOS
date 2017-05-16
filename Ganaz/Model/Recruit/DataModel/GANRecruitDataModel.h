//
//  GANRecruitDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 3/23/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GANRecruitRequestDataModel : NSObject

@property (strong, nonatomic) NSMutableArray *arrJobIds;
@property (strong, nonatomic) NSMutableArray *arrReRecruitUserIds;
@property (assign, atomic) float fBroadcast;

- (instancetype) init;
- (void) setWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) serializeToDictionary;

@end

@interface GANRecruitDataModel : NSObject

@property (strong, nonatomic) NSString *szId;
@property (strong, nonatomic) GANRecruitRequestDataModel *modelRequest;
@property (strong, nonatomic) NSMutableArray *arrReceivedUserIds;

- (instancetype) init;
- (void) setWithDictionary: (NSDictionary *) dict;

@end
