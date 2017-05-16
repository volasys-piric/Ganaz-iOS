//
//  GANJobDataModel.m
//  Ganaz
//
//  Created by Piric Djordje on 3/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANJobDataModel.h"
#import "GANUserManager.h"
#import "GANUtils.h"
#import "Global.h"
#import "GANLocationManager.h"
#import "GANGenericFunctionManager.h"
#import <CoreLocation/CoreLocation.h>
#import <float.h>

#define GANCONSTANT_CONVERSIONRATE_METRETOMILE                  1609.34

@implementation GANJobDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szId = @"";
    self.szCompanyId = @"";
    self.szTitle = @"";
    self.szTitleTranslated = @"";
    self.fPayRate = 0;
    self.enumPayUnit = GANENUM_PAY_UNIT_HOUR;
    self.dateFrom = nil;
    self.dateTo = nil;
    self.nPositions = 0;
    self.isBenefitTraining = NO;
    self.isBenefitHealth = NO;
    self.isBenefitHousing = NO;
    self.isBenefitTransportation = NO;
    self.isBenefitBonus = NO;
    self.isBenefitScholarships = NO;
    self.szComments = @"";
    self.szCommentsTranslated = @"";
    self.isAutoTranslate = NO;
    
    self.arrSite = [[NSMutableArray alloc] init];
}

- (void) initializeWithJob: (GANJobDataModel *) job{
    self.szId = job.szId;
    self.szCompanyId = job.szCompanyId;
    self.szTitle = job.szTitle;
    self.szTitleTranslated = job.szTitleTranslated;
    self.fPayRate = job.fPayRate;
    self.enumPayUnit = job.enumPayUnit;
    self.dateFrom = job.dateFrom;
    self.dateTo = job.dateTo;
    self.nPositions = job.nPositions;
    self.isBenefitTraining = job.isBenefitTraining;
    self.isBenefitHealth = job.isBenefitHealth;
    self.isBenefitHousing = job.isBenefitHousing;
    self.isBenefitTransportation = job.isBenefitTransportation;
    self.isBenefitBonus = job.isBenefitBonus;
    self.isBenefitScholarships = job.isBenefitScholarships;
    self.szComments = job.szComments;
    self.szCommentsTranslated = job.szCommentsTranslated;
    self.isAutoTranslate = job.isAutoTranslate;
    
    for (int i = 0; i < (int) [job.arrSite count]; i++){
        GANLocationDataModel *site = [job.arrSite objectAtIndex:i];
        GANLocationDataModel *siteNew = [[GANLocationDataModel alloc] init];
        [siteNew initializeWithLocation:site];
        [self.arrSite addObject:siteNew];
    }
}

- (void) setWithDictionary:(NSDictionary *)dict{
    self.szId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"_id"]];
    self.szCompanyId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"company_id"]];
    self.szTitle = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"title"]];
    self.szTitleTranslated = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"title_translated"]];
    if (self.szTitleTranslated.length == 0) self.szTitleTranslated = self.szTitle;
    
    self.szComments = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"comments"]];
    self.szCommentsTranslated = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"comments_translated"]];
    if (self.szCommentsTranslated.length == 0) self.szCommentsTranslated = self.szComments;
    
    NSDictionary *dictPay = [dict objectForKey:@"pay"];
    self.fPayRate = [GANGenericFunctionManager refineFloat:[dictPay objectForKey:@"rate"] DefaultValue:0];
    self.enumPayUnit = [GANUtils getPayUnitFromString:[GANGenericFunctionManager refineNSString:[dictPay objectForKey:@"unit"]]];
    
    NSDictionary *dictDate = [dict objectForKey:@"dates"];
    self.dateFrom = [GANGenericFunctionManager getDateTimeFromNormalizedString:[dictDate objectForKey:@"from"]];
    self.dateTo = [GANGenericFunctionManager getDateTimeFromNormalizedString:[dictDate objectForKey:@"to"]];
    
    self.nPositions = [GANGenericFunctionManager refineInt:[dict objectForKey:@"positions_available"] DefaultValue:0];
    
    NSDictionary *dictBenefits = [dict objectForKey:@"benefits"];
    self.isBenefitTraining = [GANGenericFunctionManager refineBool:[dictBenefits objectForKey:@"training"] DefaultValue:NO];
    self.isBenefitHealth = [GANGenericFunctionManager refineBool:[dictBenefits objectForKey:@"health_checks"] DefaultValue:NO];
    self.isBenefitHousing = [GANGenericFunctionManager refineBool:[dictBenefits objectForKey:@"housing"] DefaultValue:NO];
    self.isBenefitTransportation = [GANGenericFunctionManager refineBool:[dictBenefits objectForKey:@"transportation"] DefaultValue:NO];
    self.isBenefitBonus = [GANGenericFunctionManager refineBool:[dictBenefits objectForKey:@"bonus"] DefaultValue:NO];
    self.isBenefitScholarships = [GANGenericFunctionManager refineBool:[dictBenefits objectForKey:@"scholarships"] DefaultValue:NO];
    
    self.isAutoTranslate = [GANGenericFunctionManager refineBool:[dict objectForKey:@"auto_translate"] DefaultValue:NO];
    [self.arrSite removeAllObjects];
    
    NSArray *arrLocation = [dict objectForKey:@"locations"];
    for (int i = 0; i < (int) [arrLocation count]; i++){
        NSDictionary *dictLoc = [arrLocation objectAtIndex:i];
        GANLocationDataModel *location = [[GANLocationDataModel alloc] init];
        [location setWithDictionary:dictLoc];
        [self.arrSite addObject:location];
    }
}

- (NSDictionary *) serializeToDictionary{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableArray *arrSite = [[NSMutableArray alloc] init];
    for (int i = 0; i < (int) [self.arrSite count]; i++){
        GANLocationDataModel *site = [self.arrSite objectAtIndex:i];
        [arrSite addObject:[site serializeToDictionary]];
    }
    
    [dict setObject:self.szTitle forKey:@"title"];
    [dict setObject:self.szTitleTranslated forKey:@"title_translated"];
    [dict setObject:@{@"rate": @((int) self.fPayRate),
                      @"unit": ((self.enumPayUnit == GANENUM_PAY_UNIT_HOUR) ? @"hr" : @"lb")
                      }
             forKey:@"pay"];
    [dict setObject:@{@"from": [GANGenericFunctionManager getNormalizedStringFromDate:self.dateFrom],
                      @"to": [GANGenericFunctionManager getNormalizedStringFromDate:self.dateTo]
                      }
             forKey:@"dates"];
    [dict setObject:@(self.nPositions) forKey:@"positions_available"];
    [dict setObject:@{@"training": (self.isBenefitTraining == YES) ? @"true": @"false",
                      @"health_checks": (self.isBenefitHealth == YES) ? @"true": @"false",
                      @"housing": (self.isBenefitHousing == YES) ? @"true": @"false",
                      @"transportation": (self.isBenefitTransportation == YES) ? @"true": @"false",
                      @"bonus": (self.isBenefitBonus == YES) ? @"true": @"false",
                      @"scholarships": (self.isBenefitScholarships == YES) ? @"true": @"false",
                      }
             forKey:@"benefits"];
    [dict setObject:arrSite forKey:@"locations"];
    [dict setObject:self.szComments forKey:@"comments"];
    [dict setObject:self.szCommentsTranslated forKey:@"comments_translated"];
    [dict setObject:(self.isAutoTranslate == YES) ? @"true": @"false" forKey:@"auto_translate"];
    return dict;
}

- (float) getNearestDistance{
    float min = FLT_MAX;
    
    CLLocation *location = [[GANUserManager sharedInstance] getCurrentLocation];
    
    for (int i = 0; i < (int) [self.arrSite count]; i++){
        GANLocationDataModel *site = [self.arrSite objectAtIndex:i];
        CLLocation *locationSite = [site generateCLLocation];
        min = MIN(min, [location distanceFromLocation:locationSite]);
    }
    
    min = min / GANCONSTANT_CONVERSIONRATE_METRETOMILE;
    return min;
}

- (GANLocationDataModel *) getNearestSite{
    float min = FLT_MAX;
    GANLocationDataModel *siteNearest = nil;
    CLLocation *location = [GANLocationManager sharedInstance].location;
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == YES && [[GANUserManager sharedInstance] isWorker] == YES){
        location = [[GANUserManager getUserWorkerDataModel].modelLocation generateCLLocation];
    }
    
    for (int i = 0; i < (int) [self.arrSite count]; i++){
        GANLocationDataModel *site = [self.arrSite objectAtIndex:i];
        CLLocation *locationSite = [site generateCLLocation];
        if (min > [location distanceFromLocation:locationSite]){
            min = MIN(min, [location distanceFromLocation:locationSite]);
            siteNearest = site;
        }
    }
    return siteNearest;
}

- (BOOL) isPayRateSpecified{
    return (self.fPayRate > 0.01);
}

- (NSString *) getTranslatedTitle{
    if (self.isAutoTranslate == NO) return self.szTitle;
    if (self.szTitleTranslated.length == 0) return self.szTitle;
    return self.szTitleTranslated;
}

- (NSString *) getTranslatedComments{
    if (self.isAutoTranslate == NO) return self.szComments;
    if (self.szCommentsTranslated.length == 0) return self.szComments;
    return self.szCommentsTranslated;
    /*
    if (self.enumTranslateStatus == GANENUM_CONTENTS_TRANSLATE_REQUEST_STATUS_FINISHED) return self.szCommentsTranslated;
    if (self.enumTranslateStatus == GANENUM_CONTENTS_TRANSLATE_REQUEST_STATUS_REQUESTED) return self.szComments;
    
    self.enumTranslateStatus = GANENUM_CONTENTS_TRANSLATE_REQUEST_STATUS_REQUESTED;
    
    __weak typeof(self) wSelf = self;
    [GANUtils requestTranslate:self.szComments Callback:^(int status, NSString *translatedText) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (status == SUCCESS_WITH_NO_ERROR){
            sSelf.enumTranslateStatus = GANENUM_CONTENTS_TRANSLATE_REQUEST_STATUS_FINISHED;
            sSelf.szCommentsTranslated = translatedText;
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_CONTENTS_TRANSLATED object:nil];
        }
        else {
            if (sSelf.enumTranslateStatus != GANENUM_CONTENTS_TRANSLATE_REQUEST_STATUS_FINISHED){
                sSelf.enumTranslateStatus = GANENUM_CONTENTS_TRANSLATE_REQUEST_STATUS_NONE;
            }
        }
    }];
    
    return self.szComments;
     */
}

@end
