//
//  GANMessageManager.h
//  Ganaz
//
//  Created by Piric Djordje on 3/16/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANUtils.h"

@interface GANMessageManager : NSObject

@property (strong, nonatomic) NSMutableArray *arrMessages;
@property (assign, atomic) BOOL isLoading;

@property (assign, atomic) int nUnreadMessages;

+ (instancetype) sharedInstance;
- (void) initializeManager;

- (void) clearUnreadMessage;
- (int) getUnreadMessageCount;
- (void) increaseUnreadMessageCount;

#pragma mark - Request

- (void) requestGetMessageListWithCallback: (void (^) (int status)) callback;
- (void) requestSendMessageWithJobId: (NSString *) jobId Type: (GANENUM_MESSAGE_TYPE) type Receivers: (NSArray *) receiverUserIds Message: (NSString *) message AutoTranslate: (BOOL) isAutoTranslate Callback: (void (^) (int status)) callback;

@end
