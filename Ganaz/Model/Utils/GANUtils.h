//
//  GANUtils.h
//  Ganaz
//
//  Created by Piric Djordje on 3/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

// Phone Data Model

@interface GANPhoneDataModel : NSObject

@property (strong, nonatomic) NSString *szCountry;
@property (strong, nonatomic) NSString *szCountryCode;
@property (strong, nonatomic) NSString *szLocalNumber;

- (void) setWithDictionary:(NSDictionary *)dict;
- (NSDictionary *) serializeToDictionary;
- (NSString *) getBeautifiedPhoneNumber;

@end

// Location Data Model

@interface GANLocationDataModel : NSObject

@property (assign, atomic) float fLatitude;
@property (assign, atomic) float fLongitude;
@property (strong, nonatomic) NSString *szAddress;

- (void) setWithDictionary:(NSDictionary *)dict;
- (void) initializeWithLocation: (GANLocationDataModel *) location;
- (NSDictionary *) serializeToDictionary;
- (CLLocation *) generateCLLocation;

@end

// Address Data Model

@interface GANAddressDataModel : NSObject

@property (strong, nonatomic) NSString *szAddress1;
@property (strong, nonatomic) NSString *szAddress2;
@property (strong, nonatomic) NSString *szCity;
@property (strong, nonatomic) NSString *szState;
@property (strong, nonatomic) NSString *szCountry;

- (void) setWithDictionary:(NSDictionary *)dict;
- (NSDictionary *) serializeToDictionary;

@end

// Enum User Type

typedef enum _ENUM_USER_TYPE{
    GANENUM_USER_TYPE_WORKER = 0,
    GANENUM_USER_TYPE_COMPANY = 1,
}GANENUM_USER_TYPE;

// Enum User Auth Type

typedef enum _ENUM_USER_AUTHTYPE{
    GANENUM_USER_AUTHTYPE_EMAIL,
    GANENUM_USER_AUTHTYPE_FACEBOOK,
    GANENUM_USER_AUTHTYPE_TWITTER,
    GANENUM_USER_AUTHTYPE_GOOGLE,
}GANENUM_USER_AUTHTYPE;

// Enum Pay Unit

typedef enum _ENUM_PAY_UNIT{
    GANENUM_PAY_UNIT_HOUR,
    GANENUM_PAY_UNIT_LB
}GANENUM_PAY_UNIT;

// Enum Message Type

typedef enum _ENUM_MESSAGE_TYPE{
    GANENUM_MESSAGE_TYPE_MESSAGE,
    GANENUM_MESSAGE_TYPE_APPLICATION_NEW,
    GANENUM_MESSAGE_TYPE_RECRUIT,
}GANENUM_MESSAGE_TYPE;

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
    GANENUM_PUSHNOTIFICATION_TYPE_MESSAGE
}GANENUM_PUSHNOTIFICATION_TYPE;

@interface GANUtils : NSObject

+ (GANENUM_USER_TYPE) getUserTypeFromString: (NSString *) szType;
+ (NSString *) getStringFromUserType: (GANENUM_USER_TYPE) type;

+ (GANENUM_USER_AUTHTYPE) getUserAuthTypeFromString: (NSString *) szType;
+ (NSString *) getStringFromUserAuthType: (GANENUM_USER_AUTHTYPE) type;

+ (GANENUM_PAY_UNIT) getPayUnitFromString: (NSString *) szUnit;

+ (GANENUM_MESSAGE_TYPE) getMessageTypeFromString: (NSString *) szType;
+ (NSString *) getStringFromMessageType: (GANENUM_MESSAGE_TYPE) type;

+ (GANENUM_PUSHNOTIFICATION_TYPE) getPushNotificationTypeFromString: (NSString *) szType;
+ (NSString *) getStringFromPushNotificationType: (GANENUM_PUSHNOTIFICATION_TYPE) type;

+ (void) requestTranslate: (NSString *) text Translate: (BOOL) shouldTranslate Callback: (void (^) (int status, NSString *translatedText)) callback;

@end
