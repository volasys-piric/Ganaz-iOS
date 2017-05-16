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
@property (strong, nonatomic) NSString *szSenderUserId;
@property (strong, nonatomic) NSString *szMessage;
@property (strong, nonatomic) NSString *szMessageTranslated;

@property (strong, nonatomic) NSMutableArray *arrReceiverUserIds;
@property (assign, atomic) GANENUM_MESSAGE_TYPE enumType;

@property (assign, atomic) BOOL isAutoTranslate;

@property (strong, nonatomic) NSDate *dateSent;

- (instancetype) init;
- (void) setWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) serializeToDictionary;
- (BOOL) amISender;
- (BOOL) amIReceiver;
- (NSString *) getTranslatedMessage;

@end
