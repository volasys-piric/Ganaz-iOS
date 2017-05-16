//
//  GANAppManager.h
//  Ganaz
//
//  Created by Piric Djordje on 2/18/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GANAppManager : NSObject

+ (instancetype) sharedInstance;
- (void) initializeManagersAfterLaunch;
- (void) initializeManagersAfterLogin;
- (void) initializeManagersAfterLogout;

@end
