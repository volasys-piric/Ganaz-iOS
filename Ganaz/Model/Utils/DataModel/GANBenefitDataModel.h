//
//  GANBenefitDataModel.h
//  Ganaz
//
//  Created by Chris Lin on 6/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANTransContentsDataModel.h"

@interface GANBenefitDataModel : NSObject

@property (strong, nonatomic) NSString *szName;
@property (strong, nonatomic) NSString *szIcon;
@property (strong, nonatomic) GANTransContentsDataModel *modelTitle;
@property (strong, nonatomic) GANTransContentsDataModel *modelDescription;

- (void) setWithDictionary: (NSDictionary *) dict;

- (NSString *) getTitleEN;
- (NSString *) getTitleES;
- (NSString *) getDescriptionEN;
- (NSString *) getDescriptionES;

@end
