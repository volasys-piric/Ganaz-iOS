//
//  GANAppManager.m
//  Ganaz
//
//  Created by Piric Djordje on 2/18/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANAppManager.h"
#import "GANLocationManager.h"
#import "GANUserManager.h"
#import "GANJobManager.h"
#import "GANMyWorkersManager.h"
#import "GANMessageManager.h"
#import "GANReviewManager.h"
#import "GANMyCompaniesManager.h"
#import "GANRecruitManager.h"
#import "GANMembershipPlanManager.h"

#import <IQKeyboardManager.h>
#import <GoogleMaps/GoogleMaps.h>
#import "Global.h"

@implementation GANAppManager

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
        [self initializeManagers];
    }
    return self;
}

- (void) initializeManagers{
}

- (void) initializeManagersAfterLaunch{
    IQKeyboardManager *sharedInstance = [IQKeyboardManager sharedManager];
    sharedInstance.shouldResignOnTouchOutside = YES;
    sharedInstance.keyboardDistanceFromTextField = 70;
    sharedInstance.enableAutoToolbar = NO;
    
    [GMSServices provideAPIKey:GOOGLEMAPS_API_KEY];
    [[GANLocationManager sharedInstance] initializeManager];
    
    [[GANMembershipPlanManager sharedInstance] requestGetMembershipPlanListWithCallback:nil];
}

- (void) initializeManagersAfterLogin{
    GANUserManager *managerUser = [GANUserManager sharedInstance];
    if ([managerUser isCompany] == YES){
        [[GANJobManager sharedInstance] requestMyJobListWithCallback:nil];
        [[GANMyWorkersManager sharedInstance] requestGetMyWorkersListWithCallback:nil];
        [[GANMessageManager sharedInstance] requestGetMessageListWithCallback:nil];
    }
    else {
        [[GANJobManager sharedInstance] requestGetMyApplicationsWithCallback:nil];
        [[GANMessageManager sharedInstance] requestGetMessageListWithCallback:nil];
        [[GANReviewManager sharedInstance] requestGetReviewsListWithCallback:nil];
    }
}

- (void) initializeManagersAfterLogout{
    [[GANJobManager sharedInstance] initializeManager];
    [[GANMyWorkersManager sharedInstance] initializeManager];
    [[GANMessageManager sharedInstance] initializeManager];
    [[GANReviewManager sharedInstance] initializeManager];
    [[GANUserManager sharedInstance] doLogout];
    [[GANMyCompaniesManager sharedInstance] initializeManager];
    [[GANRecruitManager sharedInstance] initializeManager];
}

@end
