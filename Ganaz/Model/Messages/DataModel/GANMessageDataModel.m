//
//  GANMessageDataModel.m
//  Ganaz
//
//  Created by Piric Djordje on 3/16/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANMessageDataModel.h"
#import "GANUserManager.h"
#import "GANGenericFunctionManager.h"
#import "Global.h"

@implementation GANMessageDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szId = @"";
    self.szJobId = @"";
    self.szSenderUserId = @"";
    self.szMessage = @"";
    self.szMessageTranslated = @"";
    self.arrReceiverUserIds = [[NSMutableArray alloc] init];
    self.enumType = GANENUM_MESSAGE_TYPE_MESSAGE;
    self.isAutoTranslate = NO;
    self.dateSent = nil;
}

- (void) setWithDictionary:(NSDictionary *)dict{
    self.szId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"_id"]];
    self.szJobId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"job_id"]];
    self.szSenderUserId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"sender_user_id"]];
    self.szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"message"]];
    self.szMessageTranslated = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"message_translated"]];
    if (self.szMessageTranslated.length == 0) self.szMessageTranslated = self.szMessage;
    
    self.enumType = [GANUtils getMessageTypeFromString:[GANGenericFunctionManager refineNSString:[dict objectForKey:@"type"]]];
    self.isAutoTranslate = [GANGenericFunctionManager refineBool:[dict objectForKey:@"auto_translate"] DefaultValue:NO];
    self.dateSent = [GANGenericFunctionManager getDateTimeFromNormalizedString:[dict objectForKey:@"datetime"]];
    
    [self.arrReceiverUserIds removeAllObjects];
    NSArray *arrReceivers = [dict objectForKey:@"receivers"];
    for (int i = 0; i < (int) [arrReceivers count]; i++){
        [self.arrReceiverUserIds addObject:[GANGenericFunctionManager refineNSString:[arrReceivers objectAtIndex:i]]];
    }
}

- (NSDictionary *) serializeToDictionary{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.szJobId forKey:@"job_id"];
    [dict setObject:[GANUtils getStringFromMessageType:self.enumType] forKey:@"type"];
    [dict setObject:self.szMessage forKey:@"message"];
    [dict setObject:self.szMessageTranslated forKey:@"message_translated"];
    [dict setObject:(self.isAutoTranslate == YES) ? @"true": @"false" forKey:@"auto_translate"];
    [dict setObject:self.arrReceiverUserIds forKey:@"receivers"];    
    return dict;
}

- (BOOL) amISender{
    NSString *szUserId = [GANUserManager sharedInstance].modelUser.szId;
    return ([self.szSenderUserId isEqualToString:szUserId] == YES);
}

- (BOOL) amIReceiver{
    NSString *szUserId = [GANUserManager sharedInstance].modelUser.szId;
    for (int i = 0; i < (int) [self.arrReceiverUserIds count]; i++){
        NSString *sz = [self.arrReceiverUserIds objectAtIndex:i];
        if ([szUserId isEqualToString:sz] == YES) return YES;
    }
    return NO;
}

- (NSString *) getTranslatedMessage{
    if (self.isAutoTranslate == NO) return self.szMessage;
    if (self.szMessageTranslated.length == 0) return self.szMessage;
    return self.szMessageTranslated;
    /*
    if (self.enumTranslateStatus == GANENUM_CONTENTS_TRANSLATE_REQUEST_STATUS_FINISHED) return self.szMessageTranslated;
    if (self.enumTranslateStatus == GANENUM_CONTENTS_TRANSLATE_REQUEST_STATUS_REQUESTED) return self.szMessage;
    
    self.enumTranslateStatus = GANENUM_CONTENTS_TRANSLATE_REQUEST_STATUS_REQUESTED;
    
    __weak typeof(self) wSelf = self;
    [GANUtils requestTranslate:self.szMessage Callback:^(int status, NSString *translatedText) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (status == SUCCESS_WITH_NO_ERROR){
            sSelf.enumTranslateStatus = GANENUM_CONTENTS_TRANSLATE_REQUEST_STATUS_FINISHED;
            sSelf.szMessageTranslated = translatedText;
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_CONTENTS_TRANSLATED object:nil];
        }
        else {
            if (sSelf.enumTranslateStatus != GANENUM_CONTENTS_TRANSLATE_REQUEST_STATUS_FINISHED){
                sSelf.enumTranslateStatus = GANENUM_CONTENTS_TRANSLATE_REQUEST_STATUS_NONE;
            }
        }
    }];
    
    return self.szMessage;
     */
}

@end
