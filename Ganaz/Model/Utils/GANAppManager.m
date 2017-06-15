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
#import "GANCompanyManager.h"
#import "GANMessageManager.h"
#import "GANReviewManager.h"
#import "GANCompanyManager.h"
#import "GANRecruitManager.h"
#import "GANMembershipPlanManager.h"
#import "GANDataManager.h"

#import <IQKeyboardManager.h>
#import <GoogleMaps/GoogleMaps.h>
#import "Global.h"
#import <Mixpanel.h>

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
    [[GANDataManager sharedInstance] loadBenefits];
    
    [Mixpanel sharedInstanceWithToken:MIXPANEL_PROJECTTOKEN];
    [self logActivity:@"App launched"];
}

- (void) initializeManagersAfterLogin{
    GANUserManager *managerUser = [GANUserManager sharedInstance];
    if ([managerUser isCompanyUser] == YES){
        [[GANJobManager sharedInstance] requestMyJobListWithCallback:nil];
        [[GANCompanyManager sharedInstance] requestGetMyWorkersListWithCallback:nil];
        [[GANCompanyManager sharedInstance] requestGetCompanyUsersWithCallback:nil];
    }
    else {
        [[GANJobManager sharedInstance] requestGetMyApplicationsWithCallback:nil];
    }
    [[GANMessageManager sharedInstance] requestGetMessageListWithCallback:nil];
    [[GANReviewManager sharedInstance] requestGetReviewsListWithCallback:nil];
}

- (void) initializeManagersAfterLogout{
    [[GANJobManager sharedInstance] initializeManager];
    [[GANCompanyManager sharedInstance] initializeManager];
    [[GANMessageManager sharedInstance] initializeManager];
    [[GANReviewManager sharedInstance] initializeManager];
    [[GANUserManager sharedInstance] doLogout];
    [[GANCompanyManager sharedInstance] initializeManager];
    [[GANRecruitManager sharedInstance] initializeManager];
    GANACTIVITY_REPORT(@"User logged out");
}

- (void) logActivity: (NSString *) activity{
    [[Mixpanel sharedInstance] track:activity];
}

@end
