//
//  GANPhonebookContactDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 7/17/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANPhoneDataModel.h"
@import AddressBook;

@interface GANPhonebookContactDataModel : NSObject

@property (strong, nonatomic) NSString *szFirstName;
@property (strong, nonatomic) NSString *szLastName;
@property (strong, nonatomic) GANPhoneDataModel *modelPhone;
@property (strong, nonatomic) NSString *szEmail;

- (instancetype) init;
- (NSString *)description;
- (void) setWithPerson: (ABRecordRef) person;

- (BOOL) isValidContact;
- (BOOL) isCompleteContact;

- (NSString *) getShortName;
- (NSString *) getFullName;
- (NSString *) getInitialForIndexing;

@end
