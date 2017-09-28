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
    self.enumType = GANENUM_MESSAGE_TYPE_MESSAGE;
    self.enumStatus = GANENUM_MESSAGE_STATUS_READ;
    
    self.szSenderUserId = @"";
    self.szSenderCompanyId = @"";
    self.szReceiverUserId = @"";
    self.szReceiverCompanyId = @"";
    
    self.modelContents = [[GANTransContentsDataModel alloc] init];
    self.isAutoTranslate = NO;
    self.dateSent = nil;
    self.dictMetadata = nil;
    self.locationInfo = [[GANLocationDataModel alloc] init];
}

- (void) setWithDictionary:(NSDictionary *)dict {
    
    self.szId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"_id"]];
    self.szJobId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"job_id"]];
    self.enumType = [GANUtils getMessageTypeFromString:[GANGenericFunctionManager refineNSString:[dict objectForKey:@"type"]]];
    self.enumStatus = [GANUtils getMessageStatusFromString:[GANGenericFunctionManager refineNSString:[dict objectForKey:@"status"]]];
    
    NSDictionary *dictSender = [dict objectForKey:@"sender"];
    NSDictionary *dictReceiver = [dict objectForKey:@"receiver"];
    self.szSenderUserId = [GANGenericFunctionManager refineNSString:[dictSender objectForKey:@"user_id"]];
    self.szSenderCompanyId = [GANGenericFunctionManager refineNSString:[dictSender objectForKey:@"company_id"]];
    self.szReceiverUserId = [GANGenericFunctionManager refineNSString:[dictReceiver objectForKey:@"user_id"]];
    self.szReceiverCompanyId = [GANGenericFunctionManager refineNSString:[dictReceiver objectForKey:@"company_id"]];
    
    NSDictionary *dictContents = [dict objectForKey:@"message"];
    [self.modelContents setWithDictionary:dictContents];
    
    self.isAutoTranslate = [GANGenericFunctionManager refineBool:[dict objectForKey:@"auto_translate"] DefaultValue:NO];
    self.dictMetadata = [dict objectForKey:@"metadata"];
    
    if ([[self.dictMetadata allKeys] containsObject:@"map"]) {
        NSDictionary *dicData = [self.dictMetadata objectForKey:@"map"];
        [self.locationInfo setWithDictionary:dicData];
    }
    
    self.dateSent = [GANGenericFunctionManager getDateTimeFromNormalizedString:[dict objectForKey:@"datetime"]];
}

- (NSDictionary *) serializeToDictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.szJobId forKey:@"job_id"];
    [dict setObject:[GANUtils getStringFromMessageType:self.enumType] forKey:@"type"];
    [dict setObject:[GANUtils getStringFromMessageStatus:self.enumStatus] forKey:@"status"];
    
    [dict setObject:@{@"user_id": self.szSenderUserId,
                      @"company_id": self.szSenderCompanyId}
             forKey:@"sender"];
    [dict setObject:@{@"user_id": self.szReceiverUserId,
                      @"company_id": self.szReceiverCompanyId}
             forKey:@"receiver"];
    
    [dict setObject:[self.modelContents serializeToDictionary] forKey:@"message"];
    [dict setObject:(self.isAutoTranslate == YES) ? @"true": @"false" forKey:@"auto_translate"];
    if (self.dictMetadata != nil){
        [dict setObject:self.dictMetadata forKey:@"metadata"];
    }
    return dict;
}

- (BOOL) amISender{
    NSString *szUserId = [GANUserManager sharedInstance].modelUser.szId;
    NSString *szCompanyId = @"";
    if ([[GANUserManager sharedInstance] isCompanyUser]){
        szCompanyId = [GANUserManager getCompanyDataModel].szId;
        return ([self.szSenderCompanyId isEqualToString:szCompanyId] == YES);
    }
    else{
        return ([self.szSenderUserId isEqualToString:szUserId] == YES);
    }
    return NO;
}

- (BOOL) amIReceiver{
    NSString *szUserId = [GANUserManager sharedInstance].modelUser.szId;
    NSString *szCompanyId = @"";
    if ([[GANUserManager sharedInstance] isCompanyUser]){
        szCompanyId = [GANUserManager getCompanyDataModel].szId;
        return ([self.szReceiverCompanyId isEqualToString:szCompanyId] == YES);
    }
    else{
        return ([self.szReceiverUserId isEqualToString:szUserId] == YES);
    }
    return NO;
}

- (NSString *) getContentsEN{
    return [self.modelContents getTextEN];
}

- (NSString *) getContentsES{
    return [self.modelContents getTextES];
}

- (NSString *) getPhoneNumberForSuggestFriend{
    if (self.dictMetadata == nil) return @"";
    if (self.enumType != GANENUM_MESSAGE_TYPE_SUGGEST) return @"";
    NSString *sz = [GANGenericFunctionManager refineNSString:[self.dictMetadata objectForKey:@"suggested_phone_number"]];
    if (sz.length == 0) return @"";
    sz = [GANGenericFunctionManager stripNonnumericsFromNSString:sz];
    return [GANGenericFunctionManager beautifyPhoneNumber:sz CountryCode:@"1"];
}

- (BOOL) hasLocationInfo{
    if (self.locationInfo == nil || [self.locationInfo isValidLocation] == NO) return NO;
    return YES;
}

@end
