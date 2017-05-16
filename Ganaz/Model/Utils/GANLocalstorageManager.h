//
//  GANLocalstorageManager.h
//  Ganaz
//
//  Created by Piric Djordje on 3/25/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GANLocalstorageManager : NSObject

+ (void) saveGlobalObject: (id) obj Key: (NSString *) key;
+ (id) loadGlobalObjectWithKey: (NSString *) key;

@end
