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

- (void) setWithPerson: (ABRecordRef) person{
    [self initialize];
    
    NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
    NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
    
    self.szFirstName = [GANGenericFunctionManager refineNSString:firstName];
    self.szLastName = [GANGenericFunctionManager refineNSString:lastName];
    self.szFirstName = [self.szFirstName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    self.szLastName = [self.szLastName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phoneNumbers) > 0){
        [self.modelPhone setLocalNumber:[GANGenericFunctionManager refineNSString:(__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, 0)]];
    }
    
    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    
    for (CFIndex i = 0; i < ABMultiValueGetCount(emails); i++) {
        NSString *email = [GANGenericFunctionManager refineNSString:(__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(emails, i)];
        
        if ([GANGenericFunctionManager isValidEmailAddress:email] == YES){
            // Add Primary email only
            self.szEmail = email;
            break;
        }
    }
    GANLOG(@"%@", self);
}

- (BOOL) isValidContact{
    if (self.szFirstName.length == 0 && self.szLastName == 0) return NO;
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
