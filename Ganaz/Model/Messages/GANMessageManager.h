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

- (int) getUnreadMessageCount;

#pragma mark - Request

- (void) requestGetMessageListWithCallback: (void (^) (int status)) callback;
- (void) requestMarkAsReadAllMessagesWithCallback: (void (^) (int status)) callback;
- (void) requestSendMessageWithJobId: (NSString *) jobId
                                Type: (GANENUM_MESSAGE_TYPE) type
                           Receivers: (NSArray *) receivers
               ReceiversPhoneNumbers: (NSArray *) receivers_phone_numbers
                             Message: (NSString *) message
                            MetaData: (NSDictionary *)metaData
                       AutoTranslate: (BOOL) isAutoTranslate
                        FromLanguage: (NSString *) fromLanguage
                          ToLanguage: (NSString *) toLanguage
                            Callback: (void (^) (int status)) callback;

@end
