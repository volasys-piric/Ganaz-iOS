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
    self.isLoading = NO;
    self.nUnreadMessages = 0;
}

- (BOOL) addMessageIfNeeded: (GANMessageDataModel *) newMessage{
    if (newMessage == nil) return NO;
    for (int i = 0; i < (int) [self.arrMessages count]; i++){
        GANMessageDataModel *message = [self.arrMessages objectAtIndex:i];
        if ([message.szId isEqualToString:newMessage.szId] == YES) return NO;
    }
    [self.arrMessages addObject:newMessage];
    return YES;
}

- (void) clearUnreadMessage{
    self.nUnreadMessages = 0;
}

- (int) getUnreadMessageCount{
    return self.nUnreadMessages;
}

- (void) increaseUnreadMessageCount{
    self.nUnreadMessages++;
}

#pragma mark - Request

- (void) requestGetMessageListWithCallback: (void (^) (int status)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForGetMessages];
    self.isLoading = YES;
    
    [[GANNetworkRequestManager sharedInstance] GET:szUrl requireAuth:YES parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
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
                [self.arrMessages addObject:message];
            }
            [self clearUnreadMessage];
            
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

- (void) requestSendMessageWithJobId: (NSString *) jobId Type: (GANENUM_MESSAGE_TYPE) type Receivers: (NSArray *) receiverUserIds Message: (NSString *) message AutoTranslate: (BOOL) isAutoTranslate Callback: (void (^) (int status)) callback{
    [GANUtils requestTranslate:message Translate:isAutoTranslate Callback:^(int status, NSString *translatedText) {
        if (status != SUCCESS_WITH_NO_ERROR) translatedText = message;
        NSString *szUrl = [GANUrlManager getEndpointForSendMessage];
        GANUserManager *managerUser = [GANUserManager sharedInstance];
        NSString *szSenderUserId = managerUser.modelUser.szId;
        NSString *szSenderCompanyId = @"";
        
        if ([managerUser isCompanyUser] == YES){
            szSenderCompanyId = [GANUserManager getCompanyDataModel].szId;
        }
        
        NSDictionary *params = @{@"job_id": jobId,
                                 @"type": [GANUtils getStringFromMessageType:type],
                                 @"sender": @{@"user_id": szSenderUserId,
                                              @"company_id": szSenderCompanyId
                                              },
                                 @"receivers": receiverUserIds,
                                 @"message": @{@"en": message,
                                               @"es": translatedText
                                               },
                                 @"auto_translate": (isAutoTranslate == YES) ? @"true" : @"false"
                                 };
        
        [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:YES parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *dict = responseObject;
            BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
            if (success){
                NSDictionary *dictMessage = [dict objectForKey:@"message"];
                GANMessageDataModel *message = [[GANMessageDataModel alloc] init];
                [message setWithDictionary:dictMessage];
                [self addMessageIfNeeded:message];
                
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

@end
