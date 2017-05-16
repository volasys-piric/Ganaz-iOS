//
//  GANLocationManager.m
//  Ganaz
//
//  Created by Piric Djordje on 2/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANLocationManager.h"
#import "GANNetworkRequestManager.h"
#import "GANUrlManager.h"
#import "Global.h"
#import "GANGenericFunctionManager.h"

@implementation GANLocationManager

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
        // [self initializeManager];
        self.isLocationSet = NO;
    }
    return self;
}

- (void) dealloc{
    [self.locationManager stopUpdatingLocation];
}

- (void) initializeManager{
    if (self.locationManager != nil){
        [self.locationManager stopUpdatingLocation];
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 5;
    
    self.location = [[CLLocation alloc]initWithLatitude:GANLOCATION_DEFAULT_LATITUDE longitude:GANLOCATION_DEFAULT_LONGITUDE];
    self.szAddress = @"";
    
    [self requestCurrentLocation];
}

- (void) startLocationUpdate{
    NSLog(@"startLocationUpdate called");
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse
        && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways
        ) {
        [self.locationManager requestWhenInUseAuthorization];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.locationManager startUpdatingLocation];
        });
    }
}

- (void) stopLocationUpdate{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.locationManager stopUpdatingLocation];
    });
}

- (void) requestCurrentLocation{
    [self stopLocationUpdate];
    [self startLocationUpdate];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    switch (status) {
        case kCLAuthorizationStatusDenied:
        {
            NSLog(@"Location service is off.");
            break;
        }
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.locationManager startUpdatingLocation];
            });
            break;
        }
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    if ([locations count] == 0) return;
    CLLocation *newLocation = [locations lastObject];
    // NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    // if (locationAge < 0.01) return;
    
    if (self.isLocationSet == NO){
        self.isLocationSet = YES;
    }
    self.location = newLocation;
    [self requestAddressWithLocation:nil callback:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSString *sz = @"";
    BOOL shouldRetry = YES;
    switch([error code])
    {
        case kCLErrorNetwork:{ // general, network-related error
            sz = @"Location service failed!\nPlease check your network connection or that you are not in aireplane mode.";
            shouldRetry = YES;
            break;
        }
        case kCLErrorDenied:{
            sz = @"User denied to use location service.";
            shouldRetry = NO;
            break;
        }
        case kCLErrorLocationUnknown:{
            sz = @"Unable to obtain geo-location information right now.";
            shouldRetry = YES;
            break;
        }
        default:{
            sz = [NSString stringWithFormat:@"Location service failed due to unknown error.\n%@", error.description];
            shouldRetry = YES;
            break;
        }
    }
    NSLog(@"locationManager didFailWithError: %@", error.description);
    
    [self.locationManager stopUpdatingLocation];
    if (shouldRetry){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.locationManager startUpdatingLocation];
        });
    }
}

- (void) requestAddressWithLocation: (CLLocation *) location callback: (void (^)(NSString *szAddress)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForGooglemapsGeocode];
    CLLocation *loc = location;
    if (loc == nil) {
        loc = self.location;
    }
    
    NSString *latlng = [NSString stringWithFormat:@"%f,%f", loc.coordinate.latitude, loc.coordinate.longitude];
    NSDictionary *params = @{@"latlng" : latlng};
    
    [[GANNetworkRequestManager sharedInstance] GET:szUrl requireAuth:NO parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        @try {
            NSDictionary *dictResponse = responseObject;
            NSString *status = [GANGenericFunctionManager refineNSString:[dictResponse objectForKey:@"status"]];
            if ([status caseInsensitiveCompare:@"OK"] == NSOrderedSame){
                NSArray *results = [dictResponse objectForKey:@"results"];
                if ([results count] > 0){
                    NSDictionary *dict = [results objectAtIndex:0];
                    NSString *address = [GANGenericFunctionManager refineNSString: [dict objectForKey:@"formatted_address"]];
                    
                    if (location == nil){
                        self.szAddress = address;
                    }
                    
                    if (callback){
                        callback(address);
                    }
                    else{
                        // [[NSNotificationCenter defaultCenter] postNotificationName:ETRLOCALNOTIFICATION_LOCATION_ADDRESS_UPDATED object:nil];
                    }
                }
            } else {
                NSLog(@"Got bad status code from google maps geocode: %@", status);
                [self doFallbackGeocode];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Google maps geocode exception!");
            if (callback){
                callback(@"");
            }
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback){
            callback(@"");
        }
    }];
}

- (void) doFallbackGeocode{
    NSLog(@"Doing fallback geocoder");
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:self.location completionHandler:^(NSArray *placemarks, NSError *error){
        if (!(error)) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSLog(@"Geocoded with CLGeocoder");
            self.szAddress = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
            // [[NSNotificationCenter defaultCenter] postNotificationName:ETRLOCALNOTIFICATION_LOCATION_ADDRESS_UPDATED object:nil];
        } else {
            NSLog(@"Failover geocode failed with error %@", error);
            NSLog(@"\nCurrent Location Not Detected\n");
        }
    }];
}

@end
