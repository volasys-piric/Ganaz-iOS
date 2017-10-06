//
//  GANSurveyDataModel.m
//  Ganaz
//
//  Created by Chris Lin on 10/5/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANSurveyDataModel.h"
#import "GANGenericFunctionManager.h"
#import "Global.h"

@implementation GANSurveyDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szId = @"";
    self.enumType = GANENUM_SURVEYTYPE_CHOICESINGLE;
    self.modelOwner = [[GANUserRefDataModel alloc] init];
    self.modelQuestion = [[GANTransContentsDataModel alloc] init];
    self.arrayChoices = [[NSMutableArray alloc] init];
    self.arrayReceivers = [[NSMutableArray alloc] init];
    
    self.dictMetadata = nil;
    self.isAutoTranslate = NO;
    self.dateSent = nil;
    
    self.arrayAnswers = [[NSMutableArray alloc] init];
}

- (void) setWithDictionary:(NSDictionary *)dict {
    [self initialize];
    
    self.szId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"_id"]];
    self.enumType = [GANUtils getSurveyTypeFromString:[GANGenericFunctionManager refineNSString:[dict objectForKey:@"type"]]];
    [self.modelOwner setWithDictionary:[dict objectForKey:@"owner"]];
    [self.modelQuestion setWithDictionary:[dict objectForKey:@"question"]];
    
    NSArray *arrayChoices = [dict objectForKey:@"choices"];
    NSArray *arrayReceivers = [dict objectForKey:@"receivers"];
    
    if (arrayChoices != nil & [arrayChoices isKindOfClass:[NSArray class]] == YES) {
        for (int i = 0; i < (int) [arrayChoices count]; i++) {
            NSDictionary *dictChoice = [arrayChoices objectAtIndex:i];
            GANTransContentsDataModel *choice = [[GANTransContentsDataModel alloc] init];
            [choice setWithDictionary:dictChoice];
            [self.arrayChoices addObject:choice];
        }
    }
    if (arrayReceivers != nil & [arrayReceivers isKindOfClass:[NSArray class]] == YES) {
        for (int i = 0; i < (int) [arrayReceivers count]; i++) {
            NSDictionary *dictReceiver = [arrayReceivers objectAtIndex:i];
            GANUserRefDataModel *receiver = [[GANUserRefDataModel alloc] init];
            [receiver setWithDictionary:dictReceiver];
            [self.arrayReceivers addObject:receiver];
        }
    }
    
    self.dictMetadata = [dict objectForKey:@"metadata"];
    self.isAutoTranslate = [GANGenericFunctionManager refineBool:[dict objectForKey:@"auto_translate"] DefaultValue:NO];
    self.dateSent = [GANGenericFunctionManager getDateTimeFromNormalizedString:[dict objectForKey:@"datetime"]];
}

- (NSDictionary *) serializeToDictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[GANUtils getStringFromSurveyType:self.enumType] forKey:@"type"];
    [dict setObject:[self.modelOwner serializeToDictionary] forKey:@"owner"];
    [dict setObject:[self.modelQuestion serializeToDictionary] forKey:@"question"];
    
    NSMutableArray <NSDictionary *> *arrayChoices = [[NSMutableArray alloc] init];
    for (int i = 0; i < (int) [self.arrayChoices count]; i++) {
        GANTransContentsDataModel *choice = [self.arrayChoices objectAtIndex:i];
        [arrayChoices addObject:[choice serializeToDictionary]];
    }
    [dict setObject:arrayChoices forKey:@"choices"];
    if (self.dictMetadata != nil) {
        [dict setObject:self.dictMetadata forKey:@"metadata"];
    }
    [dict setObject:(self.isAutoTranslate == YES) ? @"true": @"false" forKey:@"auto_translate"];
    return dict;
}

@end
