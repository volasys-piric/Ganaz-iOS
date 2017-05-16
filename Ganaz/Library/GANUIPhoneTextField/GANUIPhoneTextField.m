//
//  GANUIPhoneTextField.m
//  Ganaz
//
//  Created by Piric Djordje on 2/18/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANUIPhoneTextField.h"
#import "GANGenericFunctionManager.h"

@implementation GANUIPhoneTextField

- (id) initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]){
        [self setRegionCode:@"US"];
        [self setPattern:@"(xxx) xxx-xxxx"];
        
        self.delegate = self;
        self.m_delegate = nil;
        [self addTarget:self action:@selector(onEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (void) setDelegate:(id<UITextFieldDelegate>)delegate{
    if (delegate == self){
        [super setDelegate:delegate];
    }
    else{
        self.m_delegate = delegate;
    }
}

#pragma mark -Utility

- (void) setRegionCode:(NSString *)regionCode{
    // Default: US
    self.szRegionCode = regionCode;
}

- (BOOL) isPhonenumberForUS{
    return [self.szRegionCode caseInsensitiveCompare:@"US"] == NSOrderedSame;
}

- (void) setPattern:(NSString *) pattern{
    // Default: (xxx) xxx-xxxx
    self.szPattern = pattern;
}

- (NSString *) beautifyPhoneNumber :(NSString *)szOriginalPhoneNumber isBackspace:(BOOL) isBackspace{
    szOriginalPhoneNumber = [GANGenericFunctionManager stripNonnumericsFromNSString:szOriginalPhoneNumber];
    if (szOriginalPhoneNumber.length == 11 && [szOriginalPhoneNumber hasPrefix:@"1"] == YES && [self isPhonenumberForUS] == YES){
        szOriginalPhoneNumber = [szOriginalPhoneNumber substringFromIndex:1];
    }
    
    int nMaxLength = (int) self.szPattern.length;
    NSString *szFormattedNumber = @"";
    
    int index = 0;
    for (int i = 0; i < (int) szOriginalPhoneNumber.length; i++){
        NSRange r = [self.szPattern rangeOfString:@"x" options:0 range:NSMakeRange(index, self.szPattern.length - index)];
        if (r.location == NSNotFound) break;
        
        if (r.location != index){
            // should add nun-numeric characters like whitespace or brackets
            szFormattedNumber = [NSString stringWithFormat:@"%@%@", szFormattedNumber, [self.szPattern substringWithRange:NSMakeRange(index, r.location - index)]];
        }
        szFormattedNumber = [NSString stringWithFormat:@"%@%@", szFormattedNumber, [szOriginalPhoneNumber substringWithRange:NSMakeRange(i, 1)]];
        index = (int) r.location + 1;
    }
    
    if (isBackspace == NO && szOriginalPhoneNumber.length > 0 && (szFormattedNumber.length < self.szPattern.length)){
        // Add extra non-numeric characters at the end
        NSRange r = [self.szPattern rangeOfString:@"x" options:0 range:NSMakeRange(szFormattedNumber.length, self.szPattern.length - szFormattedNumber.length)];
        if (r.location != NSNotFound){
            szFormattedNumber = [NSString stringWithFormat:@"%@%@", szFormattedNumber, [self.szPattern substringWithRange:NSMakeRange(szFormattedNumber.length, r.location - szFormattedNumber.length)]];
        }
        else {
            szFormattedNumber = [NSString stringWithFormat:@"%@%@", szFormattedNumber, [self.szPattern substringWithRange:NSMakeRange(szFormattedNumber.length, self.szPattern.length - szFormattedNumber.length)]];
        }
    }
    
    if (szFormattedNumber.length > nMaxLength){
        szFormattedNumber = [szFormattedNumber substringToIndex:nMaxLength];
    }
    
    return szFormattedNumber;
}

#pragma mark -IBAction Listener

- (IBAction)onEditingChanged:(id)sender {
    NSString *szPhone = self.text;
    NSInteger tag = self.tag;
    BOOL isBackspace = NO;
    
    if (tag == GANUIPHONETEXTFIELD_KEYPRESSED_BACKSPACE) isBackspace = YES;
    [self setText:[self beautifyPhoneNumber:szPhone isBackspace:isBackspace]];
}

// Delegate methods
#pragma mark -Editing the Text Field's Text (from Apple Document)

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (string.length == 0){
        [self setTag:GANUIPHONETEXTFIELD_KEYPRESSED_BACKSPACE];
    }
    else{
        [self setTag:0];
    }
    
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]){
        [self.m_delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(textFieldShouldClear:)]){
        [self.m_delegate textFieldShouldClear:textField];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(textFieldShouldReturn:)]){
        [self.m_delegate textFieldShouldReturn:textField];
    }
    return YES;
}

#pragma mark -Managing Editing (from Apple Document)

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]){
        [self.m_delegate textFieldShouldBeginEditing:textField];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]){
        [self.m_delegate textFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]){
        [self.m_delegate textFieldShouldEndEditing:textField];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(textFieldDidEndEditing:)]){
        [self.m_delegate textFieldDidEndEditing:textField];
    }
}

@end
