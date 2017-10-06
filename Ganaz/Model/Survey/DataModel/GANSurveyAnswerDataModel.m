//
//  GANSurveyAnswerDataModel.m
//  Ganaz
//
//  Created by Chris Lin on 10/5/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANSurveyAnswerDataModel.h"
#import "GANGenericFunctionManager.h"

@implementation GANSurveyAnswerDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szId = @"";
    self.szSurveyId = @"";
    self.indexAnswer = -1;
    self.modelAnswerText = [[GANTransContentsDataModel alloc] init];
    self.modelResponder = [[GANUserRefDataModel alloc] init];
    
    self.dictMetadata = nil;
    self.isAutoTranslate = NO;
    self.dateSent = nil;
}

- (void) setWithDictionary:(NSDictionary *)dict {
    [self initialize];
    
    self.szId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"_id"]];
    self.szSurveyId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"survey_id"]];
    
    id objectAnswer = [dict objectForKey:@"answer"];
    self.indexAnswer = [GANGenericFunctionManager refineInt:[objectAnswer objectForKey:@"index"] DefaultValue:-1];
    [self.modelAnswerText setWithDictionary:[objectAnswer objectForKey:@"text"]];
    [self.modelResponder setWithDictionary:[dict objectForKey:@"responder"]];
    
    self.dictMetadata = [dict objectForKey:@"metadata"];
    self.isAutoTranslate = [GANGenericFunctionManager refineBool:[dict objectForKey:@"auto_translate"] DefaultValue:NO];
    self.dateSent = [GANGenericFunctionManager getDateTimeFromNormalizedString:[dict objectForKey:@"datetime"]];
}

- (NSDictionary *) serializeToDictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.szSurveyId forKey:@"survey_id"];
    [dict setObject:@{@"index": (self.indexAnswer == -1) ? @"" : [NSString stringWithFormat:@"%d", self.indexAnswer],
                      @"text": [self.modelAnswerText serializeToDictionary],
                      } forKey:@"answer"];
    [dict setObject:[self.modelResponder serializeToDictionary] forKey:@"responder"];
    if (self.dictMetadata != nil) {
        [dict setObject:self.dictMetadata forKey:@"metadata"];
    }
    [dict setObject:(self.isAutoTranslate == YES) ? @"true": @"false" forKey:@"auto_translate"];
    return dict;
}

@end
