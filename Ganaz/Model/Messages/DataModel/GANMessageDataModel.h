//
//  GANMessageDataModel.h
//  Ganaz
//
//  Created by Piric Djordje on 3/16/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANSurveyDataModel.h"
#import "GANUtils.h"

@interface GANMessageReceiverDataModel : GANUserRefDataModel

@property (assign, atomic) GANENUM_MESSAGE_STATUS enumStatus;

- (instancetype) init;
- (void) setWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) serializeToDictionary;

@end

@interface GANMessageDataModel : NSObject

@property (strong, nonatomic) NSString *szId;
@property (strong, nonatomic) NSString *szJobId;
@property (assign, atomic) GANENUM_MESSAGE_TYPE enumType;

@property (strong, nonatomic) GANUserRefDataModel *modelSender;
@property (strong, nonatomic) NSMutableArray<GANMessageReceiverDataModel *> *arrayReceivers;

@property (strong, nonatomic) GANTransContentsDataModel *modelContents;
@property (assign, atomic) BOOL isAutoTranslate;

@property (strong, nonatomic) NSDictionary *dictMetadata;
@property (strong, nonatomic) NSDate *dateSent;

@property (strong, nonatomic) GANLocationDataModel *locationInfo;
@property (strong, nonatomic) NSString *szSurveyId;

- (instancetype) init;
- (void) setWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) serializeToDictionary;
- (BOOL) amISender;
- (BOOL) amIReceiver;

- (NSString *) getContentsEN;
- (NSString *) getContentsES;
- (int) getReceiversCount;
- (NSString *) getPhoneNumberForSuggestFriend;
- (GANMessageReceiverDataModel *) getPrimaryReceiver;
- (GANMessageReceiverDataModel *) getReceiverMyself;
- (BOOL) isUserInvolvedInMessage: (GANUserRefDataModel *) user;

// Message with Location

- (BOOL) hasLocationInfo;

// Group

- (BOOL) isGroupMessage;

// Survey

- (BOOL) isSurveyMessage;
- (GANSurveyDataModel *) getSurvey;

@end
