//
//  UIColor+GANColor.m
//  Ganaz
//
//  Created by Chris Lin on 10/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "UIColor+GANColor.h"

@implementation UIColor (GANColor)

// Theme
+ (UIColor *) GANThemeMainColor {
    return [UIColor colorWithRed:51 / 255.0 green:51 / 255.0 blue:51 / 255.0 alpha:1.0];
}

+ (UIColor *) GANThemeGreenColor {
    return [UIColor colorWithRed:100 / 255.0 green:179 / 255.0 blue:31 / 255.0 alpha:1.0];
}

+ (UIColor *) GANThemePlaceholderColor {
    return [UIColor colorWithRed:67 / 255.0 green:137 / 255.0 blue:6 / 255.0 alpha:1.0];
}

// Button

+ (UIColor *) GANButtonDeleteBorderColor {
    return [UIColor colorWithRed:51 / 255.0 green:51 / 255.0 blue:51 / 255.0 alpha:0.6];
}

// Badge

+ (UIColor *) GANBadgeGoldColor {
    return [UIColor colorWithRed:251 / 255.0 green:205 / 255.0 blue:67 / 255.0 alpha:1.0];
}

+ (UIColor *) GANBadgeSilverColor {
    return [UIColor colorWithRed:209 / 255.0 green:217 / 255.0 blue:223 / 255.0 alpha:1.0];
}

// Survey

+ (UIColor *) GANSurveyColor1 {
    return [UIColor colorWithRed:139 / 255.0 green:161 / 255.0 blue:86 / 255.0 alpha:1.0];
}

+ (UIColor *) GANSurveyColor2{
    return [UIColor colorWithRed:162 / 255.0 green:187 / 255.0 blue:102 / 255.0 alpha:1.0];
}

+ (UIColor *) GANSurveyColor3 {
    return [UIColor colorWithRed:187 / 255.0 green:206 / 255.0 blue:149 / 255.0 alpha:1.0];
}

+ (UIColor *) GANSurveyColor4 {
    return [UIColor colorWithRed:214 / 255.0 green:225 / 255.0 blue:196 / 255.0 alpha:1.0];
}

+ (UIColor *) GANSurveyTextColor {
    return [UIColor colorWithRed:72 / 255.0 green:77 / 255.0 blue:59 / 255.0 alpha:1.0];
}

+ (UIColor *) GANSurveyBorderColor {
    return [UIColor colorWithRed:137 / 255.0 green:158 / 255.0 blue:87 / 255.0 alpha:1.0];
}

@end
