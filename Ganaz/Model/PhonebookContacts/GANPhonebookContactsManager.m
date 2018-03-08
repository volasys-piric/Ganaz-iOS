//
//  GANPhonebookContactsManager.m
//  Ganaz
//
//  Created by Piric Djordje on 7/17/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANPhonebookContactsManager.h"
#import "GANGenericFunctionManager.h"
#import "Global.h"
@import AddressBook;

#define EMGCONSTANT_ADDRESSBOOK_MAXIMUMCONTACTS             10000

@implementation GANPhonebookContactsManager

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
        [self initializeManager];
    }
    return self;
}

- (void) initializeManager{
    self.arrContacts = [[NSMutableArray alloc] init];
    self.isContactsListBuilt = NO;
}

#pragma mark - PhoneBook

- (void) requestPermissionForAddressBookWithCallback: (void (^)(BOOL granted)) callback{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, add the contact
                if (callback) callback(YES);
            } else {
                // User denied access
                // Display an alert telling user the contact could not be added
                if (callback) callback(NO);
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        if (callback) callback(YES);
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
        if (callback) callback(NO);
    }
}

- (void) buildContactsList{
    // Build contacts list one time only.
    if (self.isContactsListBuilt == YES) return;
    
    GANLOG(@"Building contact list from phone book");
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    [self.arrContacts removeAllObjects];
    nPeople = MIN(nPeople, EMGCONSTANT_ADDRESSBOOK_MAXIMUMCONTACTS);
    
    for (int i = 0; i < nPeople; i++){
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        NSArray <GANPhonebookContactDataModel *> *arrayContactsForPerson = [self generatePhonebookContactsWithPerson:person];
        [self.arrContacts addObjectsFromArray:arrayContactsForPerson];
    }
    
    [self.arrContacts sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        GANPhonebookContactDataModel *contact1 = obj1;
        GANPhonebookContactDataModel *contact2 = obj2;
        NSString *szInitial1 = [contact1 getInitialForIndexing];
        NSString *szInitial2 = [contact2 getInitialForIndexing];
        
        if (([szInitial1 isEqualToString:@"#"] == YES) &&
            ([szInitial2 isEqualToString:@"#"] == NO)){
            return NSOrderedDescending;
        }
        if (([szInitial1 isEqualToString:@"#"] == NO) &&
            ([szInitial2 isEqualToString:@"#"] == YES)){
            return NSOrderedAscending;
        }
        
        return [[contact1 getFullName] compare:[contact2 getFullName]];
    }];
    
    self.isContactsListBuilt = YES;
}

- (NSArray <GANPhonebookContactDataModel *> *) generatePhonebookContactsWithPerson: (ABRecordRef) person {
    NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
    NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));

    firstName = [GANGenericFunctionManager refineNSString:firstName];
    lastName = [GANGenericFunctionManager refineNSString:lastName];
    firstName = [firstName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    lastName = [lastName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];

    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    NSString *email = @"";
    for (CFIndex i = 0; i < ABMultiValueGetCount(emails); i++) {
        NSString *temp = [GANGenericFunctionManager refineNSString:(__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(emails, i)];
        
        if ([GANGenericFunctionManager isValidEmailAddress:temp] == YES){
            // Add Primary email only
            email = temp;
            break;
        }
    }
    
    NSMutableArray <GANPhonebookContactDataModel *> *arrayContacts = [[NSMutableArray alloc] init];
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    int count = (int) ABMultiValueGetCount(phoneNumbers);
    
    for (int i = 0; i < count; i++) {
        NSString *phoneNumber = [GANGenericFunctionManager refineNSString:(__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i)];
        GANPhonebookContactDataModel *contact = [[GANPhonebookContactDataModel alloc] init];
        contact.szFirstName = firstName;
        contact.szLastName = lastName;
        contact.szEmail = email;
        [contact.modelPhone setLocalNumber:phoneNumber];
        if ([contact isValidContact] == YES) {
            [arrayContacts addObject:contact];
        }
    }
    return arrayContacts;
}

@end
