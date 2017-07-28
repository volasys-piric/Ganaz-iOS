//
//  GANAppConfigDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 7/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANUtils.h"

@interface GANAppConfigDataModel : NSObject

@property (assign, atomic) GANENUM_APPCONFIG_ENV enumEnv;
@property (assign, atomic) GANENUM_APPCONFIG_SERVERSTATUS enumStatus;
@property (strong, nonatomic) NSString *szBaseUrl;
@property (strong, nonatomic) NSString *szOnesignalAppId;
@property (strong, nonatomic) NSString *szMixpanelProjectToken;
@property (strong, nonatomic) NSString *szBackendVersion;
@property (strong, nonatomic) NSString *szBackendBuild;
@property (strong, nonatomic) NSString *szFrontendMinVersion;
@property (strong, nonatomic) NSString *szFrontendMinBuild;

- (void) setWithEnv: (GANENUM_APPCONFIG_ENV) env Dictionary:(NSDictionary *)dict;

@end
