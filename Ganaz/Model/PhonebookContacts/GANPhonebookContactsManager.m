//
//  GANPhonebookContactsManager.m
//  Ganaz
//
//  Created by Piric Djordje on 7/17/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANPhonebookContactsManager.h"
#import "Global.h"

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
        GANPhonebookContactDataModel *contact = [[GANPhonebookContactDataModel alloc] init];
        
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        [contact setWithPerson:person];
        if ([contact isValidContact] == YES){
            [self.arrContacts addObject:contact];
        }
        else {
        }
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

@end
