//
//  GANErrorManager.m
//  Ganaz
//
//  Created by Piric Djordje on 2/18/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANErrorManager.h"
#import "GANGenericFunctionManager.h"
#import "Global.h"

@implementation GANErrorManager

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
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.nCode = -1;
    self.szDescription = @"";
    self.szMessage = @"";
}

- (void) initializeManager{
    [self initialize];
}

- (void) logLastError{
    NSLog(@"Error %d: %@", self.nCode, self.szDescription);
}

#pragma mark -Utils

- (int) analyzeErrorResponseWithURLResponse: (NSHTTPURLResponse *) httpResponse Error: (NSError *) error ResponseObject: (NSDictionary *) dict{
    self.nCode = ERROR_CONNECTION_FAILED;
    if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        self.nCode = (int) httpResponse.statusCode;
    }
    else {
        self.szMessage = [error.userInfo objectForKey:@"NSLocalizedDescription"];
        self.szDescription = @"Sorry, we've encountered an unknown error";
        return self.nCode;
    }
    
    if (dict == nil){
        self.szMessage = @"Sorry, we've encountered an unknown error.";
        self.szDescription = @"Sorry, we've encountered an unknown error.";
        return self.nCode;
    }
    
    if ([dict isKindOfClass:[NSDictionary class]] == NO) return self.nCode;
    
    self.szMessage = @"details"; //[EMGUtil refineNSString:[dict objectForKey:@"message"]];
    self.szDescription = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"detail"]];
    return self.nCode;
}

- (int) analyzeErrorResponseWithMessage: (NSString *) message{
    message = [message lowercaseString];
    if ([message rangeOfString:@"already exists"].location != NSNotFound) return ERROR_USER_SIGNUPFAILED_PHONENUMBERCONFLICT;
    if ([message caseInsensitiveCompare:@"Username Duplicated"] == NSOrderedSame) return ERROR_USER_SIGNUPFAILED_USERNAMECONFLICT;
    if ([message caseInsensitiveCompare:@"Email Address Duplicated"] == NSOrderedSame) return ERROR_USER_SIGNUPFAILED_EMAILCONFLICT;
    if ([message caseInsensitiveCompare:@"Authentication failed. User not found."] == NSOrderedSame) return ERROR_USER_LOGINFAILED_USERNOTFOUND;
    if ([message caseInsensitiveCompare:@"Authentication failed. Wrong password."] == NSOrderedSame) return ERROR_USER_LOGINFAILED_PASSWORDWRONG;
    return ERROR_UNKNOWN;
}

+ (id) getResponseObjectFromAFError: (NSError *) error{
    
#ifndef AFNetworkingOperationFailingURLResponseDataErrorKey
    
#define AFNetworkingOperationFailingURLResponseDataErrorKey @"com.alamofire.serialization.response.error.data"
    
#endif
    if ([error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey] == nil) return nil;
    NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
    return [GANGenericFunctionManager getObjectFromJSONStringRepresentation:errResponse];
}

@end
