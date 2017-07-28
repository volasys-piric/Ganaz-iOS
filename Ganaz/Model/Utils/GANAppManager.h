//
//  GANAppManager.h
//  Ganaz
//
//  Created by Piric Djordje on 2/18/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANAppConfigDataModel.h"

@interface GANAppManager : NSObject

@property (strong, nonatomic) GANAppConfigDataModel *config;
@property (strong, nonatomic) NSString *szLatestVersion;
@property (strong, nonatomic) NSString *szLatestBuild;
@property (strong, nonatomic) NSString *szCurrentVersion;
@property (strong, nonatomic) NSString *szCurrentBuild;
@property (strong, nonatomic) NSString *szDeviceModel;
@property (assign, atomic) GANENUM_APPCONFIG_APPUPDATETYPE enumAppUpdateType;

+ (instancetype) sharedInstance;

- (void) initializeAppConfig;
- (void) initializeManagersAfterLaunch;
- (void) initializeManagersAfterAppConfig;
- (void) initializeManagersAfterLogin;
- (void) initializeManagersAfterLogout;
- (void) logActivity: (NSString *) activity;

#pragma mark - Network Requests

- (void) requestGetAppInfoFromGatewayWithCallbackCallback: (void (^) (int status)) callback;

@end
