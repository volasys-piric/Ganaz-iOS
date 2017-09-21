//
//  GANMessageDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 3/16/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANUtils.h"

@interface GANMessageDataModel : NSObject

@property (strong, nonatomic) NSString *szId;
@property (strong, nonatomic) NSString *szJobId;
@property (assign, atomic) GANENUM_MESSAGE_TYPE enumType;
@property (assign, atomic) GANENUM_MESSAGE_STATUS enumStatus;

@property (strong, nonatomic) NSString *szSenderUserId;
@property (strong, nonatomic) NSString *szSenderCompanyId;

@property (strong, nonatomic) NSString *szReceiverUserId;
@property (strong, nonatomic) NSString *szReceiverCompanyId;

@property (strong, nonatomic) GANTransContentsDataModel *modelContents;
@property (assign, atomic) BOOL isAutoTranslate;

@property (strong, nonatomic) NSDictionary *dictMetadata;
@property (strong, nonatomic) NSDate *dateSent;

@property (strong, nonatomic) GANLocationDataModel *locationInfo;

- (instancetype) init;
- (void) setWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) serializeToDictionary;
- (BOOL) amISender;
- (BOOL) amIReceiver;

- (NSString *) getContentsEN;
- (NSString *) getContentsES;
- (NSString *) getPhoneNumberForSuggestFriend;
- (BOOL) hasLocationInfo;

@end
