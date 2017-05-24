//
//  GANUtils.m
//  Ganaz
//
//  Created by Piric Djordje on 3/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANUtils.h"
#import "GANGenericFunctionManager.h"
#import "GANUrlManager.h"
#import "GANNetworkRequestManager.h"
#import "Global.h"

@implementation GANPhoneDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szCountry = @"US";
    self.szCountryCode = @"1";
    self.szLocalNumber = @"";
}

- (void) setWithDictionary:(NSDictionary *)dict{
    [self initialize];
    self.szCountry = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"country"]];
    self.szCountryCode = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"country_code"]];
    self.szLocalNumber = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"local_number"]];
}

- (NSDictionary *) serializeToDictionary{
    return @{@"country": self.szCountry,
             @"country_code": self.szCountryCode,
             @"local_number": self.szLocalNumber,
             };
}

- (NSString *) getBeautifiedPhoneNumber{
    return [GANGenericFunctionManager beautifyPhoneNumber:self.szLocalNumber CountryCode:self.szCountryCode];
}

@end

@implementation GANLocationDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.fLatitude = 0;
    self.fLongitude = 0;
    self.szAddress = @"";
}

- (void) initializeWithLocation: (GANLocationDataModel *) location{
    self.fLatitude = location.fLatitude;
    self.fLongitude = location.fLongitude;
    self.szAddress = location.szAddress;
}

- (void) setWithDictionary:(NSDictionary *)dict{
    [self initialize];
    NSArray *loc = [dict objectForKey:@"loc"];
    self.fLatitude = [GANGenericFunctionManager refineFloat:[loc objectAtIndex:1] DefaultValue:0];
    self.fLongitude = [GANGenericFunctionManager refineFloat:[loc objectAtIndex:0] DefaultValue:0];
    self.szAddress = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"address"]];
}

- (NSDictionary *) serializeToDictionary{
    return @{@"lat": [NSString stringWithFormat:@"%.6f", self.fLatitude],
             @"lng": [NSString stringWithFormat:@"%.6f", self.fLongitude],
             @"address": self.szAddress,
             };
}

- (CLLocation *) generateCLLocation{
    return [[CLLocation alloc] initWithLatitude:self.fLatitude longitude:self.fLongitude];
}

@end

@implementation GANAddressDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szAddress1 = @"";
    self.szAddress2 = @"";
    self.szCity = @"";
    self.szState = @"";
    self.szCountry = @"United States";
}

- (void) setWithDictionary:(NSDictionary *)dict{
    [self initialize];
    self.szAddress1 = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"address1"]];
    self.szAddress2 = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"address2"]];
    self.szCity = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"city"]];
    self.szState = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"state"]];
    self.szCountry = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"country"]];
}

- (NSDictionary *) serializeToDictionary{
    return @{@"address1": self.szAddress1,
             @"address2": self.szAddress2,
             @"city": self.szCity,
             @"state": self.szState,
             @"country": self.szCountry,
             };
}

@end

// Translated Contents Data Model

@implementation GANTransContentsDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szTextEN = @"";
    self.szTextES = @"";
}

- (void) setWithDictionary:(NSDictionary *)dict{
    [self initialize];
    self.szTextES = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"en"]];
    self.szTextES = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"es"]];
}

- (void) setWithContents: (GANTransContentsDataModel *) contents{
    self.szTextEN = contents.szTextEN;
    self.szTextES = contents.szTextES;
}

- (NSDictionary *) serializeToDictionary{
    return @{@"en": self.szTextEN,
             @"es": self.szTextES,
             };
}

- (NSString *) getTextEN{
    return self.szTextEN;
}

- (NSString *) getTextES{
    if (self.szTextES.length > 0) return self.szTextES;
    return self.szTextEN;
}

@end


@implementation GANUtils

// User Auth Type

+ (GANENUM_USER_AUTHTYPE) getUserAuthTypeFromString: (NSString *) szType{
    if ([szType caseInsensitiveCompare:@"email"] == NSOrderedSame){
        return GANENUM_USER_AUTHTYPE_EMAIL;
    }
    if ([szType caseInsensitiveCompare:@"facebook"] == NSOrderedSame){
        return GANENUM_USER_AUTHTYPE_FACEBOOK;
    }
    if ([szType caseInsensitiveCompare:@"twitter"] == NSOrderedSame){
        return GANENUM_USER_AUTHTYPE_TWITTER;
    }
    if ([szType caseInsensitiveCompare:@"google"] == NSOrderedSame){
        return GANENUM_USER_AUTHTYPE_GOOGLE;
    }
    return GANENUM_USER_AUTHTYPE_EMAIL;
}

+ (NSString *) getStringFromUserAuthType: (GANENUM_USER_AUTHTYPE) type{
    if (type == GANENUM_USER_AUTHTYPE_EMAIL) return @"email";
    if (type == GANENUM_USER_AUTHTYPE_FACEBOOK) return @"facebook";
    if (type == GANENUM_USER_AUTHTYPE_TWITTER) return @"twitter";
    if (type == GANENUM_USER_AUTHTYPE_GOOGLE) return @"google";
    return @"email";
}

// User Type

+ (GANENUM_USER_TYPE) getUserTypeFromString: (NSString *) szType{
    if ([szType caseInsensitiveCompare:@"worker"] == NSOrderedSame){
        return GANENUM_USER_TYPE_WORKER;
    }
    if ([szType caseInsensitiveCompare:@"company-regular"] == NSOrderedSame){
        return GANENUM_USER_TYPE_COMPANY_REGULAR;
    }
    if ([szType caseInsensitiveCompare:@"company-admin"] == NSOrderedSame){
        return GANENUM_USER_TYPE_COMPANY_ADMIN;
    }
    return GANENUM_USER_TYPE_WORKER;
}

+ (NSString *) getStringFromUserType: (GANENUM_USER_TYPE) type{
    if (type == GANENUM_USER_TYPE_WORKER) return @"worker";
    if (type == GANENUM_USER_TYPE_COMPANY_REGULAR) return @"company-regular";
    if (type == GANENUM_USER_TYPE_COMPANY_ADMIN) return @"company-admin";
    return @"worker";
}

// Pay Unit

+ (GANENUM_PAY_UNIT) getPayUnitFromString: (NSString *) szUnit{
    if ([szUnit caseInsensitiveCompare:@"hour"] == NSOrderedSame ||
        [szUnit caseInsensitiveCompare:@"hr"] == NSOrderedSame){
        return GANENUM_PAY_UNIT_HOUR;
    }
    if ([szUnit caseInsensitiveCompare:@"lb"] == NSOrderedSame){
        return GANENUM_PAY_UNIT_LB;
    }
    return GANENUM_PAY_UNIT_HOUR;
}

// Field Condition Type

+ (GANENUM_FIELDCONDITION_TYPE) getFieldConditionTypeFromString: (NSString *) szType{
    if ([szType caseInsensitiveCompare:@"poor"] == NSOrderedSame) return GANENUM_FIELDCONDITION_TYPE_POOR;
    if ([szType caseInsensitiveCompare:@"average"] == NSOrderedSame) return GANENUM_FIELDCONDITION_TYPE_AVERAGE;
    if ([szType caseInsensitiveCompare:@"good"] == NSOrderedSame) return GANENUM_FIELDCONDITION_TYPE_GOOD;
    if ([szType caseInsensitiveCompare:@"excellent"] == NSOrderedSame) return GANENUM_FIELDCONDITION_TYPE_EXCELLENT;
    return GANENUM_FIELDCONDITION_TYPE_GOOD;
}

+ (NSString *) getStringFromFieldConditionType: (GANENUM_FIELDCONDITION_TYPE) type{
    if (type == GANENUM_FIELDCONDITION_TYPE_POOR) return @"poor";
    if (type == GANENUM_FIELDCONDITION_TYPE_AVERAGE) return @"average";
    if (type == GANENUM_FIELDCONDITION_TYPE_GOOD) return @"good";
    if (type == GANENUM_FIELDCONDITION_TYPE_EXCELLENT) return @"excellent";
    
    return @"good";
}

// Message Type

+ (GANENUM_MESSAGE_TYPE) getMessageTypeFromString: (NSString *) szType{
    if ([szType caseInsensitiveCompare:@"message"] == NSOrderedSame) return GANENUM_MESSAGE_TYPE_MESSAGE;
    if ([szType caseInsensitiveCompare:@"application"] == NSOrderedSame) return GANENUM_MESSAGE_TYPE_APPLICATION;
    if ([szType caseInsensitiveCompare:@"recruit"] == NSOrderedSame) return GANENUM_MESSAGE_TYPE_RECRUIT;
    return GANENUM_MESSAGE_TYPE_MESSAGE;
}

+ (NSString *) getStringFromMessageType: (GANENUM_MESSAGE_TYPE) type{
    if (type == GANENUM_MESSAGE_TYPE_MESSAGE) return @"message";
    if (type == GANENUM_MESSAGE_TYPE_APPLICATION) return @"application";
    if (type == GANENUM_MESSAGE_TYPE_RECRUIT) return @"recruit";
    return @"message";
}

// Message Read Status

+ (GANENUM_MESSAGE_STATUS) getMessageStatusFromString: (NSString *) szStatus{
    if ([szStatus caseInsensitiveCompare:@"new"] == NSOrderedSame) return GANENUM_MESSAGE_STATUS_NEW;
    if ([szStatus caseInsensitiveCompare:@"read"] == NSOrderedSame) return GANENUM_MESSAGE_STATUS_READ;
    return GANENUM_MESSAGE_STATUS_READ;
}

+ (NSString *) getStringFromMessageStatus: (GANENUM_MESSAGE_STATUS) status{
    if (status == GANENUM_MESSAGE_STATUS_NEW) return @"new";
    if (status == GANENUM_MESSAGE_STATUS_READ) return @"read";
    return @"read";
}

// Push Notification Type

+ (GANENUM_PUSHNOTIFICATION_TYPE) getPushNotificationTypeFromString: (NSString *) szType{
    if ([szType caseInsensitiveCompare:@"recruit"] == NSOrderedSame) return GANENUM_PUSHNOTIFICATION_TYPE_RECRUIT;
    if ([szType caseInsensitiveCompare:@"message"] == NSOrderedSame) return GANENUM_PUSHNOTIFICATION_TYPE_MESSAGE;
    return GANENUM_PUSHNOTIFICATION_TYPE_NONE;
}

+ (NSString *) getStringFromPushNotificationType: (GANENUM_PUSHNOTIFICATION_TYPE) type{
    if (type == GANENUM_PUSHNOTIFICATION_TYPE_RECRUIT) return @"recruit";
    if (type == GANENUM_PUSHNOTIFICATION_TYPE_MESSAGE) return @"message";
    return @"";
}

// Membership Plan Type

+ (GANENUM_MEMBERSHIPPLAN_TYPE) getMembershipPlayTypeFromString: (NSString *) szType{
    if ([szType caseInsensitiveCompare:@"free"] == NSOrderedSame) return GANENUM_MEMBERSHIPPLAN_TYPE_FREE;
    if ([szType caseInsensitiveCompare:@"premium"] == NSOrderedSame) return GANENUM_MEMBERSHIPPLAN_TYPE_PREMIUM;
    return GANENUM_MEMBERSHIPPLAN_TYPE_FREE;
}

+ (NSString *) getStringFromMembershipPlanType: (GANENUM_MEMBERSHIPPLAN_TYPE) type{
    if (type == GANENUM_MEMBERSHIPPLAN_TYPE_FREE) return @"free";
    if (type == GANENUM_MEMBERSHIPPLAN_TYPE_PREMIUM) return @"premium";
    return @"free";
}

// Translate

+ (void) requestTranslate: (NSString *) text Translate: (BOOL) shouldTranslate Callback: (void (^) (int status, NSString *translatedText)) callback{
    if (shouldTranslate == NO){
        if (callback) callback(SUCCESS_WITH_NO_ERROR, text);
        return;
    }
    
    NSString *szUrl = [GANUrlManager getEndpointForGoogleTranslate];
    NSDictionary *params = @{@"key": GOOGLE_TRANSLATE_API_KEY,
                             @"source": @"en",
                             @"target": @"es",
                             @"q": text,
                             };
    
    [[GANNetworkRequestManager sharedInstance] GET:szUrl requireAuth:NO parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *arrTrans = [[responseObject objectForKey:@"data"] objectForKey:@"translations"];
        NSString *translatedText = [GANGenericFunctionManager refineNSString:[[arrTrans objectAtIndex:0] objectForKey:@"translatedText"]];
        if (callback) callback(SUCCESS_WITH_NO_ERROR, translatedText);
        
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(ERROR_UNKNOWN, @"");
    }];
}


@end
