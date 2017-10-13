//
//  GANGenericChart.m
//  Ganaz
//
//  Created by Chris Lin on 10/13/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANGenericChart.h"

@implementation GANGenericChart

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) setupDefaultValues{
    self.hasLegend = YES;
    self.legendPosition = PNLegendPositionBottom;
    self.legendStyle = PNLegendItemStyleStacked;
    self.labelRowsInSerialMode = 1;
    self.displayAnimated = YES;
}



/**
 *  to be implemented in subclass
 */
- (UIView*) getLegendWithMaxWidth:(CGFloat)mWidth{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void) setLabelRowsInSerialMode:(NSUInteger)num{
    if (self.legendStyle == PNLegendItemStyleSerial) {
        _labelRowsInSerialMode = num;
    }else{
        _labelRowsInSerialMode = 1;
    }
}

@end
