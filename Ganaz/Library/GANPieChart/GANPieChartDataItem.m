//
//  GANPieChartDataItem.m
//  Ganaz
//
//  Created by Chris Lin on 10/13/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANPieChartDataItem.h"

@implementation GANPieChartDataItem

+ (instancetype)dataItemWithValue:(CGFloat)value
                            color:(UIColor*)color{
    GANPieChartDataItem *item = [GANPieChartDataItem new];
    item.value = value;
    item.color  = color;
    return item;
}

+ (instancetype)dataItemWithValue:(CGFloat)value
                            color:(UIColor*)color
                      description:(NSString *)description {
    GANPieChartDataItem *item = [GANPieChartDataItem dataItemWithValue:value color:color];
    item.textDescription = description;
    return item;
}

- (void)setValue:(CGFloat)value{
    NSAssert(value >= 0, @"value should >= 0");
    if (value != _value){
        _value = value;
    }
}

@end
