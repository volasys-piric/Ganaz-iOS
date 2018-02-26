//
//  GANMessageManager.h
//  Ganaz
//
//  Created by Piric Djordje on 3/16/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANMessageThreadDataModel.h"
#import "GANUtils.h"

@interface GANMessageManager : NSObject

@property (strong, nonatomic) NSMutableArray *arrayMessages;
@property (strong, nonatomic) NSMutableArray <GANMessageThreadDataModel *> *arrayThreads;

@property (assign, atomic) BOOL isLoading;

@property (assign, atomic) int nUnreadMessages;

+ (instancetype) sharedInstance;
- (void) initializeManager;

- (int) getIndexForMessageThreadWithReceivers: (NSArray <GANUserRefDataModel *> *) arrayReceivers;
- (int) getIndexForMessageThreadWithSender: (GANUserRefDataModel *) sender;

- (int) getUnreadMessageCount;

#pragma mark - Request

- (void) requestGetMessageListWithCallback: (void (^) (int status)) callback;
- (void) requestMarkAsReadAllMessagesWithCallback: (void (^) (int status)) callback;
- (void) requestMarkAsReadWithThreadIndex: (int) indexThread Callback: (void (^) (int status)) callback;
- (void) requestSendMessageWithJobId: (NSString *) jobId
                                Type: (GANENUM_MESSAGE_TYPE) type
                           Receivers: (NSArray *) receivers
                      ReceiverPhones: (NSArray <GANPhoneDataModel *> *) receiverPhones
                             Message: (NSString *) message
                            MetaData: (NSDictionary *)metaData
                       AutoTranslate: (BOOL) isAutoTranslate
                        FromLanguage: (NSString *) fromLanguage
                          ToLanguage: (NSString *) toLanguage
                            Callback: (void (^) (int status)) callback;


#pragma mark - Utils

- (void) requestGetBeautifiedReceiversAbbrWithReceivers: (NSArray <GANUserRefDataModel *> *) arrayReceivers Callback: (void (^)(NSString *beautifiedName)) callback;

@end
