//
//  GANAppConfigDataModel.m
//  Ganaz
//
//  Created by Piric Djordje on 7/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANAppConfigDataModel.h"
#import "GANGenericFunctionManager.h"
#import "Global.h"

@implementation GANAppConfigDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.enumEnv = GANENUM_APPCONFIG_ENV_DEMO;
    self.enumStatus = GANENUM_APPCONFIG_SERVERSTATUS_RUNNING;
    self.szBaseUrl = GANURL_BASEURL;
    self.szOnesignalAppId = ONESIGNAL_APPID;
    self.szMixpanelProjectToken = MIXPANEL_PROJECTTOKEN;
    self.szBackendVersion = @"1.1";
    self.szBackendBuild = @"1100";
    self.szFrontendMinVersion = @"1.1";
    self.szFrontendMinBuild = @"1100";
}

- (void) setWithEnv: (GANENUM_APPCONFIG_ENV) env Dictionary:(NSDictionary *)dict{
    [self initialize];
    self.enumEnv = env;
    self.enumStatus = [GANUtils getAppConfigServerStatusFromString:[GANGenericFunctionManager refineNSString:[dict objectForKey:@"status"]]];
    self.szBaseUrl = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"base_url"]];
    self.szOnesignalAppId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"onesignal_appid"]];
    self.szMixpanelProjectToken = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"mixpanel_project_token"]];
    self.szBackendVersion = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"backend_version"]];
    self.szBackendBuild = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"backend_build"]];
    self.szFrontendMinVersion = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"frontend_min_version"]];
    self.szFrontendMinBuild = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"frontend_min_build"]];
}

@end
