//
//  GANTransContentsDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 6/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GANTransContentsDataModel : NSObject

@property (strong, nonatomic) NSString *szTextEN;
@property (strong, nonatomic) NSString *szTextES;

- (void) setWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) serializeToDictionary;
- (void) setWithContents: (GANTransContentsDataModel *) contents;

- (NSString *) getTextEN;
- (NSString *) getTextES;

@end
