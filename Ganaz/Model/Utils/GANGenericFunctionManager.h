//
//  GANGenericFunctionManager.h
//  Ganaz
//
//  Created by Piric Djordje on 2/18/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GANGenericFunctionManager : NSObject

+ (NSString *) getAppVersionString;
+ (NSString *) getAppBuildString;

#pragma mark -String Manipulation

+ (NSString *) refineNSString: (NSString *)sz;
+ (int) refineInt:(id)value DefaultValue: (int) defValue;
+ (float) refineFloat:(id)value DefaultValue: (float) defValue;
+ (BOOL) refineBool:(id)value DefaultValue: (BOOL) defValue;

+ (BOOL) isValidEmailAddress: (NSString *) candidate;
+ (BOOL) isValidUsername: (NSString *) candidate;
+ (NSString *) getLongStringFromDate: (NSDate *) dt;
+ (NSString *) stripNonnumericsFromNSString :(NSString *) sz;
+ (NSString *) stripNonAlphanumericsFromNSString :(NSString *) sz;
+ (NSString *) getValidPhoneNumber:(NSString *)phoneNumber;

+ (NSString *) beautifyPhoneNumber: (NSString *) localNumber CountryCode: (NSString *) countryCode;

+ (NSString *) generateRandomString :(int) length;
+ (NSString *) getBeautifiedDate: (NSDate *) dt;
+ (NSString *) getBeautifiedSpanishDate: (NSDate *) dt;
+ (NSString *) getBeautifiedLongDate: (NSDate *) dt;
+ (NSString *) getBeautifiedTime: (NSDate *) dt;
+ (NSString *) getBeautifiedRemainingTime: (NSDate *) dt;
+ (NSString *) getBeautifiedPastTime: (NSDate *) dt;
+ (NSString *)getFormattedStringFromDateTime:(NSDate *)dt;
+ (NSString *) getNormalizedStringFromDateTime:(NSDate *)dt;
+ (NSDate *) getDateTimeFromNormalizedString: (NSString *) sz;
+ (NSString *) getNormalizedStringFromDate:(NSDate *)dt;
+ (NSDate *) getDateFromNormalizedString: (NSString *) sz;

#pragma mark -Utils

+ (NSString *) getJSONStringRepresentation: (id) object;
+ (id) getObjectFromJSONStringRepresentation: (NSString *) sz;
+ (NSString *) urlEncode: (NSString *) originalString;

@end
