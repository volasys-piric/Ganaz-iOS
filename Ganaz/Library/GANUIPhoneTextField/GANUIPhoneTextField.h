//
//  GANUIPhoneTextField.h
//  Ganaz
//
//  Created by Piric Djordje on 2/18/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GANUIPhoneTextField : UITextField <UITextFieldDelegate>

#define GANUIPHONETEXTFIELD_KEYPRESSED_BACKSPACE        1000

@property (weak, nonatomic) id<UITextFieldDelegate> m_delegate;

@property (strong, nonatomic) NSString *szRegionCode;
@property (strong, nonatomic) NSString *szPattern;

- (void) setRegionCode: (NSString *) regionCode;
- (void) setPattern: (NSString *) pattern;

@end
