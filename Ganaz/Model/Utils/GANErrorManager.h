//
//  GANErrorManager.h
//  Ganaz
//
//  Created by Piric Djordje on 2/18/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GANErrorManager : NSObject

@property (atomic) int nCode;
@property (strong, nonatomic) NSString *szDescription;
@property (strong, nonatomic) NSString *szMessage;

+ (instancetype) sharedInstance;
- (void) initializeManager;
- (void) logLastError;

#pragma mark -Utils

- (int) analyzeErrorResponseWithURLResponse: (NSHTTPURLResponse *) httpResponse Error: (NSError *) error ResponseObject: (NSDictionary *) dict;
- (int) analyzeErrorResponseWithMessage: (NSString *) message;
+ (id) getResponseObjectFromAFError: (NSError *) error;

@end
