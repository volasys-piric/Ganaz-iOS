//
//  GANLocationManager.h
//  Ganaz
//
//  Created by Piric Djordje on 2/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface GANLocationManager : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSString *szAddress;
@property (assign, atomic) BOOL isLocationSet;

+ (instancetype) sharedInstance;
- (void) initializeManager;

- (void) startLocationUpdate;
- (void) stopLocationUpdate;
- (void) requestCurrentLocation;

- (void) requestAddressWithLocation: (CLLocation *) location callback: (void (^)(NSString *szAddress)) callback;

@end
