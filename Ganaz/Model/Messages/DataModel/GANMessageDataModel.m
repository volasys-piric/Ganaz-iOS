//
//  GANMessageDataModel.m
//  Ganaz
//
//  Created by Piric Djordje on 3/16/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANMessageDataModel.h"
#import "GANUserManager.h"
#import "GANSurveyManager.h"
#import "GANCacheManager.h"
#import "GANCompanyManager.h"
#import "GANGenericFunctionManager.h"
#import "Global.h"

@implementation GANMessageReceiverDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szUserId = @"";
    self.szCompanyId = @"";
    self.enumStatus = GANENUM_MESSAGE_STATUS_READ;
}

- (void) setWithDictionary:(NSDictionary *)dict{
    [super setWithDictionary:dict];
    self.enumStatus = [GANUtils getMessageStatusFromString:[GANGenericFunctionManager refineNSString:[dict objectForKey:@"status"]]];
}

- (NSDictionary *) serializeToDictionary{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super serializeToDictionary]];
    [dict setObject:[GANUtils getStringFromMessageStatus:self.enumStatus] forKey:@"status"];
    return dict;
}

@end

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

    self.modelSender = [[GANUserRefDataModel alloc] init];
    self.arrayReceivers = [[NSMutableArray alloc] init];
    
    self.modelContents = [[GANTransContentsDataModel alloc] init];
    self.isAutoTranslate = NO;
    self.dateSent = nil;
    self.dictMetadata = nil;
    self.locationInfo = [[GANLocationDataModel alloc] init];
    self.szSurveyId = @"";
}

- (void) setWithDictionary:(NSDictionary *)dict {
    
    self.szId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"_id"]];
    self.szJobId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"job_id"]];
    self.enumType = [GANUtils getMessageTypeFromString:[GANGenericFunctionManager refineNSString:[dict objectForKey:@"type"]]];
    
    NSDictionary *dictSender = [dict objectForKey:@"sender"];
    NSDictionary *dictReceiver = [dict objectForKey:@"receiver"];
    [self.modelSender setWithDictionary:dictSender];

    [self.arrayReceivers removeAllObjects];
    NSArray *arrayReceivers = [dict objectForKey:@"receivers"];
    if (arrayReceivers != nil && [arrayReceivers isKindOfClass:[NSArray class]] == YES && [arrayReceivers count] > 0) {
        for (int i = 0; i < (int) [arrayReceivers count]; i++) {
            NSDictionary *d = [arrayReceivers objectAtIndex:i];
            GANMessageReceiverDataModel *receiver = [[GANMessageReceiverDataModel alloc] init];
            [receiver setWithDictionary:d];
            [self.arrayReceivers addObject:receiver];
        }
    }
    else if (dictReceiver != nil && [dictReceiver isKindOfClass:[NSNull class]] == NO){
        GANMessageReceiverDataModel *receiver = [[GANMessageReceiverDataModel alloc] init];
        [receiver setWithDictionary:dictReceiver];
        receiver.enumStatus = [GANUtils getMessageStatusFromString:[GANGenericFunctionManager refineNSString:[dict objectForKey:@"status"]]];
        [self.arrayReceivers addObject:receiver];
    }
    
    NSDictionary *dictContents = [dict objectForKey:@"message"];
    [self.modelContents setWithDictionary:dictContents];
    
    self.isAutoTranslate = [GANGenericFunctionManager refineBool:[dict objectForKey:@"auto_translate"] DefaultValue:NO];
    self.dictMetadata = [dict objectForKey:@"metadata"];
    
    if ([[self.dictMetadata allKeys] containsObject:@"map"]) {
        NSDictionary *dicData = [self.dictMetadata objectForKey:@"map"];
        [self.locationInfo setWithDictionary:dicData];
    }
    
    if ([[self.dictMetadata allKeys] containsObject:@"survey"]) {
        self.szSurveyId = [GANGenericFunctionManager refineNSString:[[self.dictMetadata objectForKey:@"survey"] objectForKey:@"survey_id"]];
    }
    
    self.dateSent = [GANGenericFunctionManager getDateTimeFromNormalizedString:[dict objectForKey:@"datetime"]];
}

- (NSDictionary *) serializeToDictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.szJobId forKey:@"job_id"];
    [dict setObject:[GANUtils getStringFromMessageType:self.enumType] forKey:@"type"];
    [dict setObject:[self.modelSender serializeToDictionary] forKey:@"sender"];
    
    NSMutableArray *arrayReceivers = [[NSMutableArray alloc] init];
    for (int i = 0; i < (int) [self.arrayReceivers count]; i++) {
        GANMessageReceiverDataModel *receiver = [self.arrayReceivers objectAtIndex:i];
        [arrayReceivers addObject:[receiver serializeToDictionary]];
    }
    
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
        return ([self.modelSender.szCompanyId isEqualToString:szCompanyId] == YES);
    }
    else{
        return ([self.modelSender.szUserId isEqualToString:szUserId] == YES);
    }
    return NO;
}

- (BOOL) amIReceiver{
    if ([self getReceiverMyself] == nil) return NO;
    return YES;
}

- (NSString *) getContentsEN{
    return [self.modelContents getTextEN];
}

- (NSString *) getContentsES{
    return [self.modelContents getTextES];
}

- (int) getReceiversCount{
    return (int) [self.arrayReceivers count];
}

- (NSString *) getPhoneNumberForSuggestFriend{
    if (self.dictMetadata == nil) return @"";
    if (self.enumType != GANENUM_MESSAGE_TYPE_SUGGEST) return @"";
    NSString *sz = [GANGenericFunctionManager refineNSString:[self.dictMetadata objectForKey:@"suggested_phone_number"]];
    if (sz.length == 0) return @"";
    sz = [GANGenericFunctionManager stripNonnumericsFromNSString:sz];
    return [GANGenericFunctionManager beautifyPhoneNumber:sz CountryCode:@"1"];
}

- (GANMessageReceiverDataModel *) getPrimaryReceiver{
    if ([self.arrayReceivers count] == 0) return nil;
    return [self.arrayReceivers objectAtIndex:0];
}

- (GANMessageReceiverDataModel *) getReceiverMyself{
    // Extract receiver object of current user if the current user is receiver.
    
    if ([self.arrayReceivers count] == 0) return nil;
    
    NSString *szUserId = [GANUserManager sharedInstance].modelUser.szId;
    NSString *szCompanyId = @"";
    if ([[GANUserManager sharedInstance] isCompanyUser]){
        szCompanyId = [GANUserManager getCompanyDataModel].szId;
        for (int i = 0; i < (int) [self.arrayReceivers count]; i++) {
            GANMessageReceiverDataModel *receiver = [self.arrayReceivers objectAtIndex:i];
            if ([receiver.szCompanyId isEqualToString:szCompanyId] == YES) return receiver;
        }
    }
    else{
        for (int i = 0; i < (int) [self.arrayReceivers count]; i++) {
            GANMessageReceiverDataModel *receiver = [self.arrayReceivers objectAtIndex:i];
            if ([receiver.szUserId isEqualToString:szUserId] == YES) return receiver;
        }
    }
    return nil;
}

- (void) requestGetBeautifiedReceiversAbbrWithCallback: (void (^)(NSString *beautifiedName)) callback {
    // If 1 receiver: {Name / Phone number}
    // If 2+ receivers: {Primary Receiver Name / Phone number}, ... +1
    
    int nReceivers = [self getReceiversCount];
    if (nReceivers == 0) {
        if (callback) callback(@"");
        return;
    }
    
    GANMessageReceiverDataModel *receiverPrimary = [self getPrimaryReceiver];
    GANCacheManager *managerCache = [GANCacheManager sharedInstance];
    
    [managerCache requestGetIndexForUserByUserId:receiverPrimary.szUserId Callback:^(int index) {
        if (index == -1) {
            if (callback) callback(@"");
        }
        
        GANUserBaseDataModel *user = [managerCache.arrayUsers objectAtIndex:index];
        
        if ([[GANUserManager sharedInstance] isCompanyUser] == YES) {
            GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
            [managerCompany getBestUserDisplayNameWithUserId:user.szId Callback:^(NSString *displayName) {
                if (callback) {
                    if (nReceivers == 1) {
                        callback(displayName);
                    }
                    else {
                        callback([NSString stringWithFormat:@"%@, ...+%d", displayName, (nReceivers - 1)]);
                    }
                }
            }];
        }
        else {
            if (callback) {
                if (nReceivers == 1) {
                    callback([user getValidUsername]);
                }
                else {
                    callback([NSString stringWithFormat:@"%@, ...+%d", [user getValidUsername], (nReceivers - 1)]);
                }
            }
        }
    }];
}

// Message with Location

- (BOOL) hasLocationInfo{
    if (self.locationInfo == nil || [self.locationInfo isValidLocation] == NO) return NO;
    return YES;
}

// Survey

- (BOOL) isSurveyMessage{
    if (self.enumType == GANENUM_MESSAGE_TYPE_SURVEY_CHOICESINGLE ||
        self.enumType == GANENUM_MESSAGE_TYPE_SURVEY_OPENTEXT ||
        self.enumType == GANENUM_MESSAGE_TYPE_SURVEY_ANSWER) {
        if (self.szSurveyId.length > 0){
            return YES;
        }
        else {
            return NO;
        }
    }
    return NO;
}

- (GANSurveyDataModel *) getSurvey{
    if ([self isSurveyMessage] == NO) return nil;
    GANSurveyManager *managerSurvey = [GANSurveyManager sharedInstance];
    int indexSurvey = [managerSurvey getIndexForSurveyWithSurveyId:self.szSurveyId];
    if (indexSurvey == -1) return nil;
    return [managerSurvey.arraySurveys objectAtIndex:indexSurvey];
}

@end
