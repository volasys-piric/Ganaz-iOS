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
#import "GANSurveyManager.h"

#import "GANNetworkRequestManager.h"
#import "GANUrlManager.h"
#import "GANErrorManager.h"
#import "GANUtils.h"
#import "GANGenericFunctionManager.h"

#import <sys/utsname.h>
#import "IQKeyboardManager.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Global.h"
#import "Mixpanel.h"

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
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:managerUser.modelUser.szId];
    
    if ([managerUser isCompanyUser] == YES){
        [[GANJobManager sharedInstance] requestMyJobListWithCallback:nil];
        [[GANCompanyManager sharedInstance] requestGetMyWorkersListWithCallback:nil];
        [[GANCompanyManager sharedInstance] requestGetCompanyUsersWithCallback:nil];
        [[GANCompanyManager sharedInstance] requestGetCrewsListWithCallback:nil];
        [[GANSurveyManager sharedInstance] requestGetSurveyListWithCallback:nil];
        
        [mixpanel.people set:@{@"user_type": [GANUtils getStringFromUserType:managerUser.modelUser.enumType],
                               @"$email": managerUser.modelUser.szEmail,
                               @"$phone": [managerUser.modelUser.modelPhone getBeautifiedPhoneNumber],
                               @"$first_name": managerUser.modelUser.szFirstName,
                               @"$last_name": managerUser.modelUser.szLastName,
                               @"company_name": [[GANUserManager getCompanyDataModel].modelName getTextEN],
                               @"company_id": [GANUserManager getCompanyDataModel].szId,
                               }];
        GANLOG(@"User logged in => \n{User Id = %@\rUser Type = %@\rPhone = %@\rPassword = %@\rCompany Id = %@\rCompany Name = %@\r}",
               managerUser.modelUser.szId,
               [GANUtils getStringFromUserType:managerUser.modelUser.enumType],
               [managerUser.modelUser.modelPhone getBeautifiedPhoneNumber],
               managerUser.modelUser.szPassword,
               [GANUserManager getCompanyDataModel].szId,
               [[GANUserManager getCompanyDataModel].modelName getTextEN]
               );
    }
    else {
        [[GANJobManager sharedInstance] requestGetMyApplicationsWithCallback:nil];
        [[GANSurveyManager sharedInstance] requestGetSurveyAnswerListByResponderId:managerUser.modelUser.szId Callback:nil];
        
        [mixpanel.people set:@{@"$first_name": [managerUser.modelUser.modelPhone getBeautifiedPhoneNumber],
                               @"$last_name": @"",
                               @"user_type": [GANUtils getStringFromUserType:managerUser.modelUser.enumType],
                               @"$phone": [managerUser.modelUser.modelPhone getBeautifiedPhoneNumber],
                               }];
        
        GANLOG(@"User logged in => \n{User Id = %@\rUser Type = %@\rPhone = %@\rPassword = %@\r}",
               managerUser.modelUser.szId,
               [GANUtils getStringFromUserType:managerUser.modelUser.enumType],
               [managerUser.modelUser.modelPhone getBeautifiedPhoneNumber],
               managerUser.modelUser.szPassword
               );
    }
    [[GANMessageManager sharedInstance] requestGetMessageListWithCallback:nil];
    [[GANReviewManager sharedInstance] requestGetReviewsListWithCallback:nil];
    
    [CrashlyticsKit setUserIdentifier:managerUser.modelUser.szId];
    [CrashlyticsKit setUserEmail:managerUser.modelUser.szEmail];
    [CrashlyticsKit setUserName:[managerUser.modelUser.modelPhone getBeautifiedPhoneNumber]];
    
    GANACTIVITY_REPORT(@"User logged in");
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
    GANLOG(@"Activity: %@", activity);
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
