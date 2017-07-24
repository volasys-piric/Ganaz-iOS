//
//  GANTransContentsDataModel.m
//  Ganaz
//
//  Created by Piric Djordje on 6/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANTransContentsDataModel.h"
#import "GANGenericFunctionManager.h"

@implementation GANTransContentsDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szTextEN = @"";
    self.szTextES = @"";
}

- (void) setWithDictionary:(NSDictionary *)dict{
    [self initialize];
    self.szTextEN = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"en"]];
    self.szTextES = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"es"]];
}

- (void) setWithContents: (GANTransContentsDataModel *) contents{
    self.szTextEN = contents.szTextEN;
    self.szTextES = contents.szTextES;
}

- (NSDictionary *) serializeToDictionary{
    return @{@"en": self.szTextEN,
             @"es": self.szTextES,
             };
}

- (NSString *) getTextEN{
    return self.szTextEN;
}

- (NSString *) getTextES{
    if (self.szTextES.length > 0) return self.szTextES;
    return self.szTextEN;
}

@end
