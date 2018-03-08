//
//  GANMessageThreadDataModel.h
//  Ganaz
//
//  Created by Chris Lin on 10/29/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANMessageDataModel.h"
#import "GANUtils.h"

@interface GANMessageThreadDataModel : NSObject

@property (strong, nonatomic) NSMutableArray <GANMessageDataModel *> *arrayMessages;

- (instancetype) init;
- (BOOL) addMessageIfNeeded: (GANMessageDataModel *) newMessage;
- (GANMessageDataModel *) getLatestMessage;
//- (BOOL) isSameThread: (GANMessageDataModel *) message;
- (BOOL) isSameThread:(GANMessageDataModel *)message ThreadType: (GANENUM_MESSAGETHREAD_TYPE) threadType;
- (BOOL) existsMessageWithMessageId: (NSString *) messageId;
- (NSMutableArray <NSString *> *) getMessageIdsForStatusUpdateMyself;
- (int) getUnreadMessageCount;
- (BOOL) hasFacebookMessage;

@end
