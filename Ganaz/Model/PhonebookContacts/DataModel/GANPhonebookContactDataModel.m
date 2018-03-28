//
//  GANPhonebookContactDataModel.m
//  Ganaz
//
//  Created by Piric Djordje on 7/17/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANPhonebookContactDataModel.h"
#import "GANGenericFunctionManager.h"
#import "Global.h"

@implementation GANPhonebookContactDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szFirstName = @"";
    self.szLastName = @"";
    self.modelPhone = [[GANPhoneDataModel alloc] init];
    self.szEmail = @"";
}

- (NSString *)description{
    return [NSString stringWithFormat:@"{\rFirst Name = %@\rLast Name = %@\rPhone Number = %@\rEmail Address = %@\r", self.szFirstName, self.szLastName, [self.modelPhone getBeautifiedPhoneNumber], self.szEmail];
}

- (BOOL) isValidContact{
    if ([self getFullName].length == 0) return NO;
    if (self.modelPhone.szLocalNumber.length == 0) return NO;
    return YES;
}

- (BOOL) isCompleteContact{
    return ((self.szFirstName.length > 0) && (self.szLastName.length > 0) && (self.modelPhone.szLocalNumber.length > 0) && (self.szEmail.length > 0));
}

- (NSString *) getShortName{
    return @"SMS";
}

- (NSString *) getFullName{
    NSString *sz = [NSString stringWithFormat:@"%@ %@", self.szFirstName, self.szLastName];
    sz = [sz stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    return sz;
}

- (NSString *) getInitialForIndexing{
    if ([self getFullName].length == 0) return @"#";
    NSString *sz = [[self getFullName] substringToIndex:1];
    
    NSCharacterSet *alphabets = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"];
    
    //Check against alphabets
    NSRange range = [sz rangeOfCharacterFromSet:[alphabets invertedSet]];
    if (range.location != NSNotFound) {
        return @"#";
    }
    return [sz uppercaseString];
}

@end
