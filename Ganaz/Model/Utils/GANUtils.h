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
#import "GANUserRefDataModel.h"

#import "UIImageView+AFNetworking.h"

typedef enum _ENUM_USER_TYPE{
    GANENUM_USER_TYPE_ANY = -1,
    GANENUM_USER_TYPE_WORKER = 0,
    GANENUM_USER_TYPE_COMPANY_REGULAR = 1,
    GANENUM_USER_TYPE_COMPANY_ADMIN = 2,
    GANENUM_USER_TYPE_ONBOARDING_WORKER = 3
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
/*
typedef enum _ENUM_PAY_UNIT{
    GANENUM_PAY_UNIT_HOUR,
    GANENUM_PAY_UNIT_LB
}GANENUM_PAY_UNIT;
*/
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
    GANENUM_MESSAGE_TYPE_SURVEY_CHOICESINGLE,
    GANENUM_MESSAGE_TYPE_SURVEY_OPENTEXT,
    GANENUM_MESSAGE_TYPE_SURVEY_ANSWER,
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

// Enum: App Config AppUpdate Type

typedef enum _ENUM_APPCONFIG_APPUPDATETYPE{
    GANENUM_APPCONFIG_APPUPDATETYPE_NONE,
    GANENUM_APPCONFIG_APPUPDATETYPE_MANDATORY,
    GANENUM_APPCONFIG_APPUPDATETYPE_OPTIONAL
}GANENUM_APPCONFIG_APPUPDATETYPE;

// Enum: Survey Type

typedef enum _ENUM_SURVEYTYPE{
    GANENUM_SURVEYTYPE_CHOICESINGLE,
    GANENUM_SURVEYTYPE_OPENTEXT,
}GANENUM_SURVEYTYPE;

// Enum: Reference Type to Worker Signup

typedef enum _ENUM_ONBOARDINGACTION_FROM {
    GANENUM_ONBOARDINGACTION_LOGINFROM_DEFAULT = 0,
    GANENUM_ONBOARDINGACTION_LOGINFROM_WORKER_JOBAPPLY = 1000,
    GANENUM_ONBOARDINGACTION_LOGINFROM_WORKER_SUGGESTFRIEND = 1001,
}GANENUM_ONBOARDINGACTION_LOGINFROM;

// Enum: Reference Type to Company Signup

typedef enum company_signup_from_vc {
    ENUM_DEFAULT_SIGNUP = 0,
    ENUM_JOBPOST_SIGNUP,
    ENUM_COMMUNICATE_SIGNUP,
    ENUM_RETAIN_SIGNUP
} ENUM_COMPANY_SIGNUP_FROM_CUSTOMVC;

typedef enum company_addworkers_from_vc {
    ENUM_COMPANY_ADDWORKERS_FROM_HOME = 0,
    ENUM_COMPANY_ADDWORKERS_FROM_MESSAGE,
    ENUM_COMPANY_ADDWORKERS_FROM_RECRUITJOB,
    ENUM_COMPANY_ADDWORKERS_FROM_RETAINMYWORKERS
} ENUM_COMPANY_ADDWORKERS_FROM_CUSTOMVC;

typedef enum company_sharePostingWithContactFrom_vc {
    ENUM_COMPANY_SHAREPOSTINGWITHCONTACT_FROM_HOME = 0,
    ENUM_COMPANY_SHAREPOSTINGWITHCONTACT_FROM_JOBPOST
} ENUM_COMPANY_SHAREPOSTINGWITHCONTACT_FROM_CUSTOMVC;

// Enum: Deferred Deep Link Action Type

typedef enum _ENUM_BRANCHDEEPLINK_ACTION{
    GANENUM_BRANCHDEEPLINK_ACTION_NONE,
    GANENUM_BRANCHDEEPLINK_ACTION_WORKER_SIGNUPWITHPHONE,
}GANENUM_BRANCHDEEPLINK_ACTION;

// Country

typedef enum _ENUM_PHONE_COUNTRY{
    GANENUM_PHONE_COUNTRY_US = 1,           // United States
    GANENUM_PHONE_COUNTRY_MX = 52,          // Mexico
}GANENUM_PHONE_COUNTRY;

#define GANCONSTANTS_TRANSLATE_LANGUAGE_EN                      @"en"
#define GANCONSTANTS_TRANSLATE_LANGUAGE_ES                      @"es"

@interface GANUtils : NSObject

+ (GANENUM_USER_TYPE) getUserTypeFromString: (NSString *) szType;
+ (NSString *) getStringFromUserType: (GANENUM_USER_TYPE) type;

+ (GANENUM_USER_AUTHTYPE) getUserAuthTypeFromString: (NSString *) szType;
+ (NSString *) getStringFromUserAuthType: (GANENUM_USER_AUTHTYPE) type;

+ (NSString*) getPayUnitFromString: (NSString *) szUnit;

+ (GANENUM_FIELDCONDITION_TYPE) getFieldConditionTypeFromString: (NSString *) szType;
+ (NSString *) getStringFromFieldConditionType: (GANENUM_FIELDCONDITION_TYPE) type;

+ (GANENUM_MESSAGE_TYPE) getMessageTypeFromString: (NSString *) szType;
+ (NSString *) getStringFromMessageType: (GANENUM_MESSAGE_TYPE) type;

+ (GANENUM_MESSAGE_STATUS) getMessageStatusFromString: (NSString *) szStatus;
+ (NSString *) getStringFromMessageStatus: (GANENUM_MESSAGE_STATUS) status;

+ (GANENUM_PUSHNOTIFICATION_TYPE) getPushNotificationTypeFromString: (NSString *) szType;
+ (NSString *) getStringFromPushNotificationType: (GANENUM_PUSHNOTIFICATION_TYPE) type;

// Phone Country

+ (GANENUM_PHONE_COUNTRY) getCountryFromString: (NSString *) szCountry;
+ (NSString *) getStringFromCountry: (GANENUM_PHONE_COUNTRY) country;

// App Config

+ (GANENUM_APPCONFIG_ENV) getAppConfigEnvFromString: (NSString *) szEnv;
+ (NSString *) getStringFromAppConfigEnv: (GANENUM_APPCONFIG_ENV) env;

+ (GANENUM_APPCONFIG_SERVERSTATUS) getAppConfigServerStatusFromString: (NSString *) szStatus;
+ (NSString *) getStringFromAppConfigServerStatus: (GANENUM_APPCONFIG_SERVERSTATUS) status;

// Membership Plan Type

+ (GANENUM_MEMBERSHIPPLAN_TYPE) getMembershipPlayTypeFromString: (NSString *) szType;
+ (NSString *) getStringFromMembershipPlanType: (GANENUM_MEMBERSHIPPLAN_TYPE) type;

// Survey Type
+ (GANENUM_SURVEYTYPE) getSurveyTypeFromString: (NSString *) szType;
+ (NSString *) getStringFromSurveyType: (GANENUM_SURVEYTYPE) type;

+ (void) syncImageWithUrl:(UIImageView *) imageView latitude:(float) latitude longitude:(float) longitude;
                                 
+ (void) requestTranslate: (NSString *) text
                Translate: (BOOL) shouldTranslate
             FromLanguage: (NSString *) fromLanguage
               ToLanguage: (NSString *) toLanguage
                 Callback: (void (^) (int status, NSString *translatedText)) callback;

+ (void) requestTranslateEsMultipleTexts: (NSArray <NSString *>*) texts
                               Translate: (BOOL) shouldTranslate
                                Callback:(void (^)(int, NSArray <GANTransContentsDataModel *> *))callback;

@end
