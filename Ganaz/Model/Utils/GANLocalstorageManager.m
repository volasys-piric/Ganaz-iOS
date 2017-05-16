//
//  GANLocalstorageManager.m
//  Ganaz
//
//  Created by Piric Djordje on 3/25/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANLocalstorageManager.h"
#import "Global.h"

@implementation GANLocalstorageManager

+ (void) saveGlobalObject: (id) obj Key: (NSString *) key{
    NSString *szKey = [NSString stringWithFormat:@"%@%@", LOCALSTORAGE_PREFIX, key];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (obj) {
        [userDefaults setObject:obj forKey:szKey];
    } else {
        [userDefaults removeObjectForKey:szKey];
    }
    
    [userDefaults synchronize];
}

+ (id) loadGlobalObjectWithKey: (NSString *) key{
    NSString *szKey = [NSString stringWithFormat:@"%@%@", LOCALSTORAGE_PREFIX, key];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:szKey];
}

@end
