//
//  GANLocationDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 6/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GANLocationDataModel : NSObject

@property (assign, atomic) float fLatitude;
@property (assign, atomic) float fLongitude;
@property (strong, nonatomic) NSString *szAddress;

- (void) setWithDictionary:(NSDictionary *)dict;
- (void) initializeWithLocation: (GANLocationDataModel *) location;
- (NSDictionary *) serializeToDictionary;
- (NSDictionary *) serializeToMetaDataDictionary;
- (CLLocation *) generateCLLocation;
- (BOOL) isValidLocation;

@end
