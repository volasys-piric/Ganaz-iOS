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

#import "GANNetworkRequestManager.h"
#import "GANUrlManager.h"
#import "GANErrorManager.h"
#import "GANUtils.h"
#import "GANGenericFunctionManager.h"

#import <sys/utsname.h>
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

- (void) initializeAppConfig{
    self.config = [[GANAppConfigDataModel alloc] init];
#if     defined(GANENVIRONMENT_STAGING)
    self.config.enumEnv = GANENUM_APPCONFIG_ENV_STAGING;
#elif   defined(GANENVIRONMENT_DEMO)
    self.config.enumEnv = GANENUM_APPCONFIG_ENV_DEMO;
#else
    self.config.enumEnv = GANENUM_APPCONFIG_ENV_PRODUCTION;
#endif
    
    self.config.enumStatus = GANENUM_APPCONFIG_SERVERSTATUS_RUNNING;
    self.config.szBaseUrl = GANURL_BASEURL;
    self.config.szOnesignalAppId = ONESIGNAL_APPID;
    self.config.szMixpanelProjectToken = MIXPANEL_PROJECTTOKEN;
    self.config.szBackendVersion = @"1.1";
    self.config.szBackendBuild = @"1100";
    self.config.szFrontendMinVersion = @"1.1";
    self.config.szFrontendMinBuild = @"1100";
    
    self.szCurrentVersion = [GANGenericFunctionManager getAppVersionString];
    self.szCurrentBuild = [GANGenericFunctionManager getAppBuildString];
    self.szLatestVersion = self.szCurrentVersion;
    self.szLatestBuild = self.szCurrentBuild;
    self.enumAppUpdateType = GANENUM_APPCONFIG_APPUPDATETYPE_NONE;
    
    struct utsname systemInfo;
    uname(&systemInfo);
    self.szDeviceModel = [NSString stringWithCString:systemInfo.machine
                                            encoding:NSUTF8StringEncoding];
}

- (void) initializeManagersAfterLaunch{
    IQKeyboardManager *sharedInstance = [IQKeyboardManager sharedManager];
    sharedInstance.shouldResignOnTouchOutside = YES;
    sharedInstance.keyboardDistanceFromTextField = 70;
    sharedInstance.enableAutoToolbar = NO;
    [[GANLocationManager sharedInstance] initializeManager];
}

- (void) initializeManagersAfterAppConfig{
    [GMSServices provideAPIKey:GOOGLEMAPS_API_KEY];
    
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

- (void) checkAppUpdates{
    int nCurrentBuild = [self.szCurrentBuild intValue];
    int nLatestBuild = [self.szLatestBuild intValue];
    int nMinBuild = [self.config.szFrontendMinBuild intValue];
    
    if (nCurrentBuild < nLatestBuild){
        if (nCurrentBuild < nMinBuild){
            self.enumAppUpdateType = GANENUM_APPCONFIG_APPUPDATETYPE_MANDATORY;
            return;
        }
        self.enumAppUpdateType = GANENUM_APPCONFIG_APPUPDATETYPE_OPTIONAL;
        return;
    }
    self.enumAppUpdateType = GANENUM_APPCONFIG_APPUPDATETYPE_NONE;
}

#pragma mark - Network Requests

- (void) requestGetAppInfoFromGatewayWithCallbackCallback: (void (^) (int status)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForAppConfig];
    
    [[GANNetworkRequestManager sharedInstance] GET:szUrl requireAuth:NO parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        GANLOG(@"App Config ===> %@", responseObject);
        
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSString *szEnv = [GANUtils getStringFromAppConfigEnv:self.config.enumEnv];
            NSDictionary *dictConfig = [[dict objectForKey:@"config"] objectForKey:szEnv];
            [self.config setWithEnv:self.config.enumEnv Dictionary:dictConfig];
            
            NSDictionary *dictIOS = [[[dict objectForKey:@"config"] objectForKey:@"frontend"] objectForKey:@"ios"];
            self.szLatestVersion = [GANGenericFunctionManager refineNSString:[dictIOS objectForKey:@"latest_version"]];
            self.szLatestBuild = [GANGenericFunctionManager refineNSString:[dictIOS objectForKey:@"latest_build"]];

            // Test Code
//            self.szLatestVersion = @"1.3";
//            self.szLatestBuild = @"1300";
//            self.config.szFrontendMinVersion = @"1.3";
//            self.config.szFrontendMinBuild = @"1300";
            
            [self checkAppUpdates];
            
            [self initializeManagersAfterAppConfig];
            if (callback) callback(SUCCESS_WITH_NO_ERROR);
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
    }];
}

@end
