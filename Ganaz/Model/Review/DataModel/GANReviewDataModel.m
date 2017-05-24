//
//  GANReviewDataModel.m
//  Ganaz
//
//  Created by Piric Djordje on 3/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANReviewDataModel.h"
#import "GANGenericFunctionManager.h"

@implementation GANReviewDataModel

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
    self.szWorkerUserId = @"";
    self.szComments = @"";
    self.ratingPay = 0;
    self.ratingBenefits = 0;
    self.ratingSupervisors = 0;
    self.ratingSafety = 0;
    self.ratingTrust = 0;
}

- (void) setWithDictionary:(NSDictionary *)dict{
    self.szId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"_id"]];
    self.szCompanyId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"company_id"]];
    self.szWorkerUserId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"worker_user_id"]];
    self.szComments = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"comments"]];
    
    NSDictionary *dictRating = [dict objectForKey:@"rating"];
    self.ratingPay = [GANGenericFunctionManager refineInt:[dictRating objectForKey:@"pay"] DefaultValue:0];
    self.ratingBenefits = [GANGenericFunctionManager refineInt:[dictRating objectForKey:@"benefits"] DefaultValue:0];
    self.ratingSupervisors = [GANGenericFunctionManager refineInt:[dictRating objectForKey:@"supervisors"] DefaultValue:0];
    self.ratingSafety = [GANGenericFunctionManager refineInt:[dictRating objectForKey:@"safety"] DefaultValue:0];
    self.ratingTrust = [GANGenericFunctionManager refineInt:[dictRating objectForKey:@"trust"] DefaultValue:0];
}

- (NSDictionary *) serializeToDictionary{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.szCompanyId forKey:@"company_id"];
    [dict setObject:self.szWorkerUserId forKey:@"worker_user_id"];
    [dict setObject:self.szComments forKey:@"comments"];
    [dict setObject:@{@"pay": @(self.ratingPay),
                      @"benefits": @(self.ratingBenefits),
                      @"supervisors": @(self.ratingSupervisors),
                      @"safety": @(self.ratingSafety),
                      @"trust": @(self.ratingTrust),
                      } forKey:@"rating"];
    return dict;
}

- (int) getRatingAtIndex: (int) index{
    if (index == 0) return self.ratingPay;
    if (index == 1) return self.ratingBenefits;
    if (index == 2) return self.ratingSupervisors;
    if (index == 3) return self.ratingSafety;
    if (index == 4) return self.ratingTrust;
    return self.ratingPay;
}

- (void) setRating: (int) rating AtIndex: (int) index{
    if (index == 0) self.ratingPay = rating;
    if (index == 1) self.ratingBenefits = rating;
    if (index == 2) self.ratingSupervisors = rating;
    if (index == 3) self.ratingSafety = rating;
    if (index == 4) self.ratingTrust = rating;
}

- (float) getAverageRating{
    return (self.ratingPay + self.ratingBenefits + self.ratingSupervisors + self.ratingSafety + self.ratingTrust) / 5.0;
}

@end
