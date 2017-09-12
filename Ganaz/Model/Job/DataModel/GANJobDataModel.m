//
//  GANJobDataModel.m
//  Ganaz
//
//  Created by Piric Djordje on 3/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANJobDataModel.h"
#import "GANUserManager.h"
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
    self.szCompanyUserId = @"";
    self.modelTitle = [[GANTransContentsDataModel alloc] init];
    self.modelComments = [[GANTransContentsDataModel alloc] init];
    self.isAutoTranslate = NO;
    self.fPayRate = 0;
    self.szPayUnit = @"";
    self.dateFrom = nil;
    self.dateTo = nil;
    self.nPositions = 0;
    self.enumFieldCondition = GANENUM_FIELDCONDITION_TYPE_GOOD;
    self.isBenefitTraining = NO;
    self.isBenefitHealth = NO;
    self.isBenefitHousing = NO;
    self.isBenefitTransportation = NO;
    self.isBenefitBonus = NO;
    self.isBenefitScholarships = NO;
    
    self.arrSite = [[NSMutableArray alloc] init];
}

- (void) initializeWithJob: (GANJobDataModel *) job{
    self.szId = job.szId;
    self.szCompanyId = job.szCompanyId;
    self.szCompanyUserId = job.szCompanyUserId;
    [self.modelTitle setWithContents:job.modelTitle];
    [self.modelComments setWithContents:job.modelComments];
    self.fPayRate = job.fPayRate;
    self.szPayUnit = job.szPayUnit;
    self.dateFrom = job.dateFrom;
    self.dateTo = job.dateTo;
    self.nPositions = job.nPositions;
    self.enumFieldCondition = job.enumFieldCondition;
    
    self.isBenefitTraining = job.isBenefitTraining;
    self.isBenefitHealth = job.isBenefitHealth;
    self.isBenefitHousing = job.isBenefitHousing;
    self.isBenefitTransportation = job.isBenefitTransportation;
    self.isBenefitBonus = job.isBenefitBonus;
    self.isBenefitScholarships = job.isBenefitScholarships;
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
    self.szCompanyUserId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"company_user_id"]];
    
    NSDictionary *dictTitle = [dict objectForKey:@"title"];
    NSDictionary *dictComments = [dict objectForKey:@"comments"];
    [self.modelTitle setWithDictionary:dictTitle];
    [self.modelComments setWithDictionary:dictComments];
    self.isAutoTranslate = [GANGenericFunctionManager refineBool:[dict objectForKey:@"auto_translate"] DefaultValue:NO];

    NSDictionary *dictPay = [dict objectForKey:@"pay"];
    self.fPayRate = [GANGenericFunctionManager refineFloat:[dictPay objectForKey:@"rate"] DefaultValue:0];
    self.szPayUnit = [GANUtils getPayUnitFromString:[GANGenericFunctionManager refineNSString:[dictPay objectForKey:@"unit"]]];
    
    NSDictionary *dictDate = [dict objectForKey:@"dates"];
    self.dateFrom = [GANGenericFunctionManager getDateTimeFromNormalizedString:[dictDate objectForKey:@"from"]];
    self.dateTo = [GANGenericFunctionManager getDateTimeFromNormalizedString:[dictDate objectForKey:@"to"]];
    
    self.nPositions = [GANGenericFunctionManager refineInt:[dict objectForKey:@"positions_available"] DefaultValue:0];
    self.enumFieldCondition = [GANUtils getFieldConditionTypeFromString:[GANGenericFunctionManager refineNSString:[dict objectForKey:@"field_condition"]]];
    
    NSDictionary *dictBenefits = [dict objectForKey:@"benefits"];
    self.isBenefitTraining = [GANGenericFunctionManager refineBool:[dictBenefits objectForKey:@"training"] DefaultValue:NO];
    self.isBenefitHealth = [GANGenericFunctionManager refineBool:[dictBenefits objectForKey:@"health_checks"] DefaultValue:NO];
    self.isBenefitHousing = [GANGenericFunctionManager refineBool:[dictBenefits objectForKey:@"housing"] DefaultValue:NO];
    self.isBenefitTransportation = [GANGenericFunctionManager refineBool:[dictBenefits objectForKey:@"transportation"] DefaultValue:NO];
    self.isBenefitBonus = [GANGenericFunctionManager refineBool:[dictBenefits objectForKey:@"bonus"] DefaultValue:NO];
    self.isBenefitScholarships = [GANGenericFunctionManager refineBool:[dictBenefits objectForKey:@"scholarships"] DefaultValue:NO];
    
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
    
    [dict setObject:self.szCompanyId forKey:@"company_id"];
    [dict setObject:self.szCompanyUserId forKey:@"company_user_id"];
    [dict setObject:[self.modelTitle serializeToDictionary] forKey:@"title"];
    [dict setObject:[self.modelComments serializeToDictionary] forKey:@"comments"];
    [dict setObject:(self.isAutoTranslate == YES) ? @"true": @"false" forKey:@"auto_translate"];

    [dict setObject:@{@"rate": [NSString stringWithFormat:@"%.2f", self.fPayRate],
                      @"unit": self.szPayUnit
                      }
             forKey:@"pay"];
    [dict setObject:@{@"from": [GANGenericFunctionManager getNormalizedStringFromDate:self.dateFrom],
                      @"to": [GANGenericFunctionManager getNormalizedStringFromDate:self.dateTo]
                      }
             forKey:@"dates"];
    [dict setObject:@(self.nPositions) forKey:@"positions_available"];
    [dict setObject:[GANUtils getStringFromFieldConditionType:self.enumFieldCondition] forKey:@"field_condition"];
    [dict setObject:@{@"training": (self.isBenefitTraining == YES) ? @"true": @"false",
                      @"health_checks": (self.isBenefitHealth == YES) ? @"true": @"false",
                      @"housing": (self.isBenefitHousing == YES) ? @"true": @"false",
                      @"transportation": (self.isBenefitTransportation == YES) ? @"true": @"false",
                      @"bonus": (self.isBenefitBonus == YES) ? @"true": @"false",
                      @"scholarships": (self.isBenefitScholarships == YES) ? @"true": @"false",
                      }
             forKey:@"benefits"];
    [dict setObject:arrSite forKey:@"locations"];
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

- (NSString *) getTitleEN{
    return [self.modelTitle getTextEN];
}

- (NSString *) getTitleES{
    return [self.modelTitle getTextES];
}

- (NSString *) getCommentsEN{
    return [self.modelComments getTextEN];
}

- (NSString *) getCommentsES{
    return [self.modelComments getTextES];
}


@end
