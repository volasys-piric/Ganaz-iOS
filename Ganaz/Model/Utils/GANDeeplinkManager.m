//
//  GANDeeplinkManager.m
//  Ganaz
//
//  Created by Chris Lin on 12/13/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANDeeplinkManager.h"
#import "GANGenericFunctionManager.h"

@implementation GANDeeplinkManager

+ (instancetype) sharedInstance{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init{
    if (self = [super init]){
        [self initializeManager];
    }
    return self;
}

- (void) initializeManager{
    self.enumAction = GANENUM_BRANCHDEEPLINK_ACTION_NONE;
    self.szPhoneNumber = @"";
}


+ (GANENUM_BRANCHDEEPLINK_ACTION) getBranchActionTypeFromString: (NSString *) action {
    if ([action caseInsensitiveCompare:@"wsp"] == NSOrderedSame) return GANENUM_BRANCHDEEPLINK_ACTION_WORKER_SIGNUPWITHPHONE;
    return GANENUM_BRANCHDEEPLINK_ACTION_NONE;
}

// Branch.io Deferred DeepLink Analyzer

- (void) analyzeBranchDeeplink: (NSDictionary *) params {
    [self initializeManager];
    
    NSString *action = [GANGenericFunctionManager refineNSString:[params objectForKey:@"action"]];
    self.enumAction = [GANDeeplinkManager getBranchActionTypeFromString:action];
    if (self.enumAction == GANENUM_BRANCHDEEPLINK_ACTION_WORKER_SIGNUPWITHPHONE) {
        self.szPhoneNumber = [GANGenericFunctionManager refineNSString:[params objectForKey:@"p"]];
    }
}

@end
