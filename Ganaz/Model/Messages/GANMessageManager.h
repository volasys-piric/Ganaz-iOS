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
@property (strong, nonatomic) NSMutableArray <GANMessageThreadDataModel *> *arrayGeneralThreads;
@property (strong, nonatomic) NSMutableArray <GANMessageThreadDataModel *> *arrayCandidateThreads;

@property (assign, atomic) BOOL isLoading;

@property (assign, atomic) int nUnreadMessages;

+ (instancetype) sharedInstance;
- (void) initializeManager;

- (int) getIndexForGeneralMessageThreadWithReceivers: (NSArray <GANUserRefDataModel *> *) arrayReceivers;
- (int) getIndexForGeneralMessageThreadWithSender: (GANUserRefDataModel *) sender;

- (int) getIndexForCandidateMessageThreadWithReceivers: (NSArray <GANUserRefDataModel *> *) arrayReceivers;
- (int) getIndexForCandidateMessageThreadWithSender: (GANUserRefDataModel *) sender;
- (void) addMessageToCandidateThread: (GANMessageDataModel *) newMessage;
- (void) generateCandidateThreadsByCandidates: (NSArray <GANUserRefDataModel *> *) arrayCandidates;

- (int) getUnreadGeneralMessageCount;
- (int) getUnreadCandidateMessageCount;

#pragma mark - Request

- (void) requestGetMessageListWithCallback: (void (^) (int status)) callback;
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


- (void) requestMarkAsReadAllGeneralMessagesWithCallback: (void (^) (int status)) callback;
- (void) requestMarkAsReadAllCandidateMessagesWithCallback: (void (^) (int status)) callback;
- (void) requestMarkAsReadWithGeneralThreadIndex: (int) indexThread Callback: (void (^) (int status)) callback;
- (void) requestMarkAsReadWithCandidateThreadIndex: (int) indexThread Callback: (void (^) (int status)) callback;

#pragma mark - Utils

- (void) requestGetBeautifiedReceiversAbbrWithReceivers: (NSArray <GANUserRefDataModel *> *) arrayReceivers Callback: (void (^)(NSString *beautifiedName)) callback;

@end
