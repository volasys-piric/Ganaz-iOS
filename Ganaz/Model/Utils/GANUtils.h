//
//  GANUtils.h
//  Ganaz
//
//  Created by Piric Djordje on 3/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GANPhoneDataModel.h"
#import "GANLocationDataModel.h"
#import "GANAddressDataModel.h"
#import "GANTransContentsDataModel.h"
#import "GANBenefitDataModel.h"

typedef enum _ENUM_USER_TYPE{
    GANENUM_USER_TYPE_ANY = -1,
    GANENUM_USER_TYPE_WORKER = 0,
    GANENUM_USER_TYPE_COMPANY_REGULAR = 1,
    GANENUM_USER_TYPE_COMPANY_ADMIN = 2,
}GANENUM_USER_TYPE;

// Enum User Auth Type

typedef enum _ENUM_USER_AUTHTYPE{
    GANENUM_USER_AUTHTYPE_EMAIL,
    GANENUM_USER_AUTHTYPE_FACEBOOK,
    GANENUM_USER_AUTHTYPE_TWITTER,
    GANENUM_USER_AUTHTYPE_GOOGLE,
    GANENUM_USER_AUTHTYPE_PHONE,
}GANENUM_USER_AUTHTYPE;

// Enum Pay Unit

typedef enum _ENUM_PAY_UNIT{
    GANENUM_PAY_UNIT_HOUR,
    GANENUM_PAY_UNIT_LB
}GANENUM_PAY_UNIT;

// Enum Field Condition

typedef enum _ENUM_FIELDCONDITION_TYPE{
    GANENUM_FIELDCONDITION_TYPE_POOR,
    GANENUM_FIELDCONDITION_TYPE_AVERAGE,
    GANENUM_FIELDCONDITION_TYPE_GOOD,
    GANENUM_FIELDCONDITION_TYPE_EXCELLENT,
}GANENUM_FIELDCONDITION_TYPE;

// Enum Message Type

typedef enum _ENUM_MESSAGE_TYPE{
    GANENUM_MESSAGE_TYPE_MESSAGE,
    GANENUM_MESSAGE_TYPE_APPLICATION,
    GANENUM_MESSAGE_TYPE_SUGGEST,
    GANENUM_MESSAGE_TYPE_RECRUIT,
}GANENUM_MESSAGE_TYPE;

// Enum Message Read Status

typedef enum _ENUM_MESSAGE_STATUS{
    GANENUM_MESSAGE_STATUS_NEW,
    GANENUM_MESSAGE_STATUS_READ,
}GANENUM_MESSAGE_STATUS;

// Enum Company Badge Type

typedef enum _ENUM_COMPANY_BADGE_TYPE{
    GANENUM_COMPANY_BADGE_TYPE_NONE,
    GANENUM_COMPANY_BADGE_TYPE_SILVER,
    GANENUM_COMPANY_BADGE_TYPE_GOLD,
}GANENUM_COMPANY_BADGE_TYPE;

// Enum Contents Translate Request Status

typedef enum _ENUM_CONTENTS_TRANSLATE_REQUEST_STATUS{
    GANENUM_CONTENTS_TRANSLATE_REQUEST_STATUS_NONE,
    GANENUM_CONTENTS_TRANSLATE_REQUEST_STATUS_REQUESTED,
    GANENUM_CONTENTS_TRANSLATE_REQUEST_STATUS_FINISHED,
}GANENUM_CONTENTS_TRANSLATE_REQUEST_STATUS;

// Enum Push Notification Type

typedef enum _ENUM_PUSHNOTIFICATION_TYPE{
    GANENUM_PUSHNOTIFICATION_TYPE_NONE,
    GANENUM_PUSHNOTIFICATION_TYPE_RECRUIT,
    GANENUM_PUSHNOTIFICATION_TYPE_MESSAGE,
    GANENUM_PUSHNOTIFICATION_TYPE_APPLICATION,
    GANENUM_PUSHNOTIFICATION_TYPE_SUGGEST,
}GANENUM_PUSHNOTIFICATION_TYPE;

// Enum Membership Plan Type

typedef enum _ENUM_MEMBERSHIPPLAN_TYPE{
    GANENUM_MEMBERSHIPPLAN_TYPE_FREE,
    GANENUM_MEMBERSHIPPLAN_TYPE_PREMIUM,
}GANENUM_MEMBERSHIPPLAN_TYPE;

// Enum App Config Environment

typedef enum _ENUM_APPCONFIG_ENV{
    GANENUM_APPCONFIG_ENV_STAGING,
    GANENUM_APPCONFIG_ENV_DEMO,
    GANENUM_APPCONFIG_ENV_PRODUCTION
}GANENUM_APPCONFIG_ENV;

// Enum App Config Server Status

typedef enum _ENUM_APPCONFIG_SERVERSTATUS{
    GANENUM_APPCONFIG_SERVERSTATUS_RUNNING,
    GANENUM_APPCONFIG_SERVERSTATUS_MAINTENANCE,
    GANENUM_APPCONFIG_SERVERSTATUS_DOWN
}GANENUM_APPCONFIG_SERVERSTATUS;

// Enum App Config AppUpdate Type

typedef enum _ENUM_APPCONFIG_APPUPDATETYPE{
    GANENUM_APPCONFIG_APPUPDATETYPE_NONE,
    GANENUM_APPCONFIG_APPUPDATETYPE_MANDATORY,
    GANENUM_APPCONFIG_APPUPDATETYPE_OPTIONAL
}GANENUM_APPCONFIG_APPUPDATETYPE;

#define GANCONSTANTS_TRANSLATE_LANGUAGE_EN                      @"en"
#define GANCONSTANTS_TRANSLATE_LANGUAGE_ES                      @"es"

@interface GANUtils : NSObject

+ (GANENUM_USER_TYPE) getUserTypeFromString: (NSString *) szType;
+ (NSString *) getStringFromUserType: (GANENUM_USER_TYPE) type;

+ (GANENUM_USER_AUTHTYPE) getUserAuthTypeFromString: (NSString *) szType;
+ (NSString *) getStringFromUserAuthType: (GANENUM_USER_AUTHTYPE) type;

+ (GANENUM_PAY_UNIT) getPayUnitFromString: (NSString *) szUnit;

+ (GANENUM_FIELDCONDITION_TYPE) getFieldConditionTypeFromString: (NSString *) szType;
+ (NSString *) getStringFromFieldConditionType: (GANENUM_FIELDCONDITION_TYPE) type;

+ (GANENUM_MESSAGE_TYPE) getMessageTypeFromString: (NSString *) szType;
+ (NSString *) getStringFromMessageType: (GANENUM_MESSAGE_TYPE) type;

+ (GANENUM_MESSAGE_STATUS) getMessageStatusFromString: (NSString *) szStatus;
+ (NSString *) getStringFromMessageStatus: (GANENUM_MESSAGE_STATUS) status;

+ (GANENUM_PUSHNOTIFICATION_TYPE) getPushNotificationTypeFromString: (NSString *) szType;
+ (NSString *) getStringFromPushNotificationType: (GANENUM_PUSHNOTIFICATION_TYPE) type;

// App Config

+ (GANENUM_APPCONFIG_ENV) getAppConfigEnvFromString: (NSString *) szEnv;
+ (NSString *) getStringFromAppConfigEnv: (GANENUM_APPCONFIG_ENV) env;

+ (GANENUM_APPCONFIG_SERVERSTATUS) getAppConfigServerStatusFromString: (NSString *) szStatus;
+ (NSString *) getStringFromAppConfigServerStatus: (GANENUM_APPCONFIG_SERVERSTATUS) status;

// Membership Plan Type

+ (GANENUM_MEMBERSHIPPLAN_TYPE) getMembershipPlayTypeFromString: (NSString *) szType;
+ (NSString *) getStringFromMembershipPlanType: (GANENUM_MEMBERSHIPPLAN_TYPE) type;

+ (void) requestTranslate: (NSString *) text
                Translate: (BOOL) shouldTranslate
             FromLanguage: (NSString *) fromLanguage
               ToLanguage: (NSString *) toLanguage
                 Callback: (void (^) (int status, NSString *translatedText)) callback;

+ (BOOL)validatePhoneNumber:(NSString *)phoneNumber;

@end
