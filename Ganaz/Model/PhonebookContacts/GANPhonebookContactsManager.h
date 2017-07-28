//
//  GANPhonebookContactsManager.h
//  Ganaz
//
//  Created by Piric Djordje on 7/17/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANPhonebookContactDataModel.h"

@interface GANPhonebookContactsManager : NSObject

@property (strong, nonatomic) NSMutableArray <GANPhonebookContactDataModel *> *arrContacts;
@property (assign, atomic) BOOL isContactsListBuilt;

+ (instancetype) sharedInstance;
- (void) initializeManager;

#pragma mark - PhoneBook

- (void) requestPermissionForAddressBookWithCallback: (void (^)(BOOL granted)) callback;
- (void) buildContactsList;

@end
