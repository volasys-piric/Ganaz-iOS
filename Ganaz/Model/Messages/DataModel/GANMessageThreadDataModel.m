//
//  GANMessageThreadDataModel.m
//  Ganaz
//
//  Created by Chris Lin on 10/29/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANMessageThreadDataModel.h"
#import "GANUserManager.h"

@implementation GANMessageThreadDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.arrayMessages = [[NSMutableArray alloc] init];
}

- (BOOL) addMessageIfNeeded: (GANMessageDataModel *) newMessage{
    if (newMessage == nil) return NO;
    int index = 0;
    for (int i = 0; i < (int) [self.arrayMessages count]; i++){
        GANMessageDataModel *message = [self.arrayMessages objectAtIndex:i];
        if ([message.szId isEqualToString:newMessage.szId] == YES) return NO;
        
        if ([message.dateSent compare:newMessage.dateSent] == NSOrderedAscending) {
            index = index + 1;
        }
    }
    
    // order by datetime
    if ([self.arrayMessages count] <= index) {
        [self.arrayMessages addObject:newMessage];
    }
    else {
        [self.arrayMessages insertObject:newMessage atIndex:index];
    }
    return YES;
}

- (GANMessageDataModel *) getLatestMessage {
    if ([self.arrayMessages count] == 0) return nil;
    return [self.arrayMessages lastObject];
}

- (BOOL) isSameThread: (GANMessageDataModel *) message{
    GANMessageDataModel *messageLatest = [self getLatestMessage];
    if (messageLatest == nil) return NO;
    
    if ([[GANUserManager sharedInstance] isCompanyUser] == YES) {
        // It's same thread in the following 2 cases... (A: Company, B, C: Worker)
        // [Case 1] Sender1 == Sender2 && Receivers1 == Receivers2       Ex: (A->B,C, A->B,C) || (B->A, B-A)
        // [Case 2] Sender1 == Receivers2 && Sender2 == Receivers1     Ex: (A->B, B->A)
        
        // Attention! A->B,C && B->A are not same thread in Company section...
        
        // [Case 1]
        if ([messageLatest.modelSender isSameUser:message.modelSender] == YES) {
            if ([messageLatest.arrayReceivers count] != [message.arrayReceivers count]) {
                return NO;
            }
            
            BOOL isSame = YES;
            for (int i = 0; i < (int) [messageLatest.arrayReceivers count]; i++) {
                GANMessageReceiverDataModel *receiver1 = [messageLatest.arrayReceivers objectAtIndex:i];
                BOOL found = NO;
                for (int j = 0; j < (int) [message.arrayReceivers count]; j++) {
                    GANMessageReceiverDataModel *receiver2 = [message.arrayReceivers objectAtIndex:j];
                    if ([receiver1 isSameUser:receiver2] == YES) {
                        found = YES;
                        break;
                    }
                }
                
                if (found == NO) {
                    isSame = NO;
                    break;
                }
            }
            
            if (isSame == NO) {
                return NO;
            }
            
            return YES;
        }
        
        // [Case 2]
        if ([messageLatest.arrayReceivers count] != 1) return NO;
        if ([message.arrayReceivers count] != 1) return NO;
        
        GANMessageReceiverDataModel *receiver1 = [messageLatest getPrimaryReceiver];
        GANMessageReceiverDataModel *receiver2 = [message getPrimaryReceiver];
        
        if ([messageLatest.modelSender isSameUser:receiver2] == YES &&
            [message.modelSender isSameUser:receiver1] == YES) {
            return YES;
        }
        return NO;
    }
    else {
        // It's same thread in the following 4 cases...     (A: Company, B, C, D: Worker)
        // [Case 1] (Message1.sender == Myself) && (Message2.sender == Myself)                                  Ex:  (B->A, B->A)
        // [Case 2] (Message1.receivers INCLUDES myself) && (Message2.receivers INCLUDES myself)                Ex:  (A->B,C, A->B,D)
        // [Case 3] (Message1.receivers INCLUDES myself) && (Message2.sender == Myself)                         Ex:  (A->B,C, B->A)
        // [Case 4] (Message1.sender == Myself) && (Message2.receivers INCLUDES myself)                         Ex:  (B->A, A->B,C)
        
        // [Case 1]
        if ([messageLatest amISender] == YES && [message amISender] == YES) {
            if ([[messageLatest getPrimaryReceiver] isSameUser:[message getPrimaryReceiver]] == YES) {
                return YES;
            }
            return NO;
        }
        // [Case 2]
        else if ([messageLatest amISender] == NO && [message amISender] == NO){
            if ([messageLatest.modelSender isSameUser:message.modelSender] == YES) {
                return YES;
            }
            return NO;
        }
        // [Case 3]
        else if ([messageLatest amISender] == NO && [message amISender] == YES){
            if ([messageLatest.modelSender isSameUser:[message getPrimaryReceiver]] == YES) {
                return YES;
            }
            return NO;
        }
        // [Case 4]
        else if ([messageLatest amISender] == YES && [message amISender] == NO){
            if ([[messageLatest getPrimaryReceiver] isSameUser:message.modelSender] == YES) {
                return YES;
            }
            return NO;
        }
        return NO;
    }
    return NO;
}

- (BOOL) existsMessageWithMessageId: (NSString *) messageId {
    for (int i = 0; i < (int) [self.arrayMessages count]; i++) {
        GANMessageDataModel *message = [self.arrayMessages objectAtIndex:i];
        if ([message.szId isEqualToString:messageId] == YES) return YES;
    }
    return NO;
}

- (NSMutableArray <NSString *> *) getMessageIdsForStatusUpdateMyself{
    NSMutableArray <NSString *> *arrayMessageIds = [[NSMutableArray alloc] init];
    for (int i = 0; i < (int) [self.arrayMessages count]; i++){
        GANMessageDataModel *message = [self.arrayMessages objectAtIndex:i];
        GANMessageReceiverDataModel *receiver = [message getReceiverMyself];
        if (receiver != nil && receiver.enumStatus == GANENUM_MESSAGE_STATUS_NEW) {
            [arrayMessageIds addObject:message.szId];
        }
    }
    return arrayMessageIds;
}

- (int) getUnreadMessageCount{
    int count = 0;
    for (int i = 0; i < (int) [self.arrayMessages count]; i++){
        GANMessageDataModel *message = [self.arrayMessages objectAtIndex:i];
        GANMessageReceiverDataModel *receiver = [message getReceiverMyself];
        if (receiver != nil && receiver.enumStatus == GANENUM_MESSAGE_STATUS_NEW) count++;
    }
    return count;
}

@end
