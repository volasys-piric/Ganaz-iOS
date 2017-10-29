//
//  GANMessageManager.m
//  Ganaz
//
//  Created by Piric Djordje on 3/16/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANMessageManager.h"
#import "GANMessageDataModel.h"
#import "GANUserManager.h"
#import "GANNetworkRequestManager.h"
#import "GANUrlManager.h"
#import "GANGenericFunctionManager.h"
#import "GANErrorManager.h"
#import "Global.h"
#import "GANGlobalVCManager.h"

@implementation GANMessageManager

+ (instancetype) sharedInstance{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init{
    if (self = [super init]){
        [self initializeManager];
    }
    return self;
}

- (void) initializeManager{
    self.arrMessages = [[NSMutableArray alloc] init];
    self.arrayThreads = [[NSMutableArray alloc] init];
    self.isLoading = NO;
    self.nUnreadMessages = 0;
}

- (int) getIndexForMessageWithId: (NSString *) messageId{
    for (int i = 0; i < (int) [self.arrMessages count]; i++){
        GANMessageDataModel *message = [self.arrMessages objectAtIndex:i];
        if ([message.szId isEqualToString:messageId] == YES) return i;
    }
    return -1;
}

- (BOOL) addMessageIfNeeded: (GANMessageDataModel *) newMessage{
    if (newMessage == nil) return NO;
    for (int i = 0; i < (int) [self.arrMessages count]; i++){
        GANMessageDataModel *message = [self.arrMessages objectAtIndex:i];
        if ([message.szId isEqualToString:newMessage.szId] == YES) return NO;
    }
    [self.arrMessages addObject:newMessage];
    [self addMessageToThread:newMessage];
    return YES;
}

- (void) addMessageToThread: (GANMessageDataModel *) newMessage{
    if (newMessage == nil) return;
    for (int i = 0; i < (int) [self.arrayThreads count]; i++) {
        GANMessageThreadDataModel *thread = [self.arrayThreads objectAtIndex:i];
        if ([thread isSameThread:newMessage] == YES) {
            [thread addMessageIfNeeded:newMessage];
            return;
        }
    }
    
    // Create new thread && add message
    GANMessageThreadDataModel *newThread = [[GANMessageThreadDataModel alloc] init];
    [newThread addMessageIfNeeded:newMessage];
    [self.arrayThreads addObject:newThread];
}

- (int) getUnreadMessageCount{
    int count = 0;
    for (int i = 0; i < (int) [self.arrMessages count]; i++){
        GANMessageDataModel *message = [self.arrMessages objectAtIndex:i];
        GANMessageReceiverDataModel *receiver = [message getReceiverMyself];
        if (receiver != nil && receiver.enumStatus == GANENUM_MESSAGE_STATUS_NEW) count++;
    }
    return count;
}

#pragma mark - Request

- (void) requestGetMessageListWithCallback: (void (^) (int status)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForGetMessages];
    NSDictionary *param;
    if ([[GANUserManager sharedInstance] isCompanyUser]){
        param = @{@"company_id": [GANUserManager getCompanyDataModel].szId};
    }
    else {
        param = @{@"user_id": [GANUserManager sharedInstance].modelUser.szId};
    }

    self.isLoading = YES;
    
    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:YES parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        self.isLoading = NO;
        
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSArray *arrMessages = [dict objectForKey:@"messages"];
            [self.arrMessages removeAllObjects];
            
            for (int i = 0; i < (int) [arrMessages count]; i++){
                NSDictionary *dictMessage = [arrMessages objectAtIndex:i];
                GANMessageDataModel *message = [[GANMessageDataModel alloc] init];
                [message setWithDictionary:dictMessage];
                [self addMessageIfNeeded:message];
            }
            [GANGlobalVCManager updateMessageBadge];
            
            if (callback) callback(SUCCESS_WITH_NO_ERROR);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_MESSAGE_LIST_UPDATED object:nil];
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_MESSAGE_LIST_UPDATEFAILED object:nil];
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_MESSAGE_LIST_UPDATEFAILED object:nil];
    }];
}

- (void) requestSendMessageWithJobId: (NSString *) jobId
                                Type: (GANENUM_MESSAGE_TYPE) type
                           Receivers: (NSArray *) receivers
               ReceiversPhoneNumbers: (NSArray *) receivers_phone_numbers
                             Message: (NSString *) message
                            MetaData: (NSDictionary *)metaData
                       AutoTranslate: (BOOL) isAutoTranslate
                        FromLanguage: (NSString *) fromLanguage
                          ToLanguage: (NSString *) toLanguage
                            Callback: (void (^) (int status)) callback{
    
    [GANUtils requestTranslate:message Translate:isAutoTranslate FromLanguage:fromLanguage ToLanguage:toLanguage Callback:^(int status, NSString *translatedText) {
        if (status != SUCCESS_WITH_NO_ERROR) translatedText = message;
        NSString *szUrl = [GANUrlManager getEndpointForSendMessage];
        GANUserManager *managerUser = [GANUserManager sharedInstance];
        NSString *szSenderUserId = managerUser.modelUser.szId;
        NSString *szSenderCompanyId = @"";
        
        if ([managerUser isCompanyUser] == YES){
            szSenderCompanyId = [GANUserManager getCompanyDataModel].szId;
        }
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:jobId forKey:@"job_id"];
        [params setObject:[GANUtils getStringFromMessageType:type] forKey:@"type"];
        [params setObject:@{@"user_id": szSenderUserId,
                            @"company_id": szSenderCompanyId
                            } forKey:@"sender"];
        if(receivers.count > 0)
            [params setObject:receivers forKey:@"receivers"];
        
        [params setObject:@{fromLanguage: message,
                            toLanguage: translatedText
                            } forKey:@"message"];
        if(metaData != nil)
            [params setObject:metaData forKey:@"metadata"];
        
        [params setObject:(isAutoTranslate == YES) ? @"true" : @"false" forKey:@"auto_translate"];
        
        if(receivers_phone_numbers.count > 0) {
            [params setObject:receivers_phone_numbers forKey:@"receivers_phone_numbers"];
        }
        
        [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:YES parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *dict = responseObject;
            BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
            if (success){
                NSArray *arrMessages = [dict objectForKey:@"messages"];
                for (int i = 0; i < (int) [arrMessages count]; i++){
                    NSDictionary *dictMessage = [arrMessages objectAtIndex:i];
                    GANMessageDataModel *message = [[GANMessageDataModel alloc] init];
                    [message setWithDictionary:dictMessage];
                    [self addMessageIfNeeded:message];
                }
                [GANGlobalVCManager updateMessageBadge];
                
                if (callback) callback(SUCCESS_WITH_NO_ERROR);
                [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_MESSAGE_LIST_UPDATED object:nil];
            }
            else {
                NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
                if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
                [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_MESSAGE_LIST_UPDATEFAILED object:nil];
            }
        } failure:^(int status, NSDictionary *error) {
            if (callback) callback(status);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_MESSAGE_LIST_UPDATEFAILED object:nil];
        }];
    }];
}

- (void) requestMarkAsReadAllMessagesWithCallback: (void (^) (int status)) callback{
    NSMutableArray *arrMessageIds = [[NSMutableArray alloc] init];
    for (int i = 0; i < (int) [self.arrMessages count]; i++){
        GANMessageDataModel *message = [self.arrMessages objectAtIndex:i];
        GANMessageReceiverDataModel *receiver = [message getReceiverMyself];
        if (receiver != nil && receiver.enumStatus == GANENUM_MESSAGE_STATUS_NEW) {
            [arrMessageIds addObject:message.szId];
        }
    }
    [self requestMarkAsRead:arrMessageIds Callback:callback];
}

- (void) requestMarkAsRead: (NSArray *) arrMessageIds Callback: (void (^) (int status)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForMessageMarkAsRead];
    NSDictionary *param = @{@"message_ids": arrMessageIds,
                            @"status": @"read"};
    
    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:YES parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            for (int i = 0; i < (int) [arrMessageIds count]; i++){
                NSString *messageId = [arrMessageIds objectAtIndex:i];
                int index = [self getIndexForMessageWithId:messageId];
                if (index == -1) continue;
                
                GANMessageDataModel *message = [self.arrMessages objectAtIndex:index];
                GANMessageReceiverDataModel *receiver = [message getReceiverMyself];
                if (receiver != nil) {
                    receiver.enumStatus = GANENUM_MESSAGE_STATUS_READ;
                }
            }
            
            [GANGlobalVCManager updateMessageBadge];
            
            if (callback) callback(SUCCESS_WITH_NO_ERROR);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_MESSAGE_LIST_UPDATED object:nil];
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_MESSAGE_LIST_UPDATEFAILED object:nil];
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_MESSAGE_LIST_UPDATEFAILED object:nil];
    }];
}

@end
