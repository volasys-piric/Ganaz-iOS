//
//  GANPieChartDelegate.h
//  Ganaz
//
//  Created by Chris Lin on 10/13/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#ifndef GANPieChartDelegate_h
#define GANPieChartDelegate_h

#import <Foundation/Foundation.h>

@protocol GANChartDelegate <NSObject>
@optional
/**
 * Callback method that gets invoked when the user taps on the chart line.
 */
- (void)userClickedOnLinePoint:(CGPoint)point lineIndex:(NSInteger)lineIndex;

/**
 * Callback method that gets invoked when the user taps on a chart line key point.
 */
- (void)userClickedOnLineKeyPoint:(CGPoint)point
                        lineIndex:(NSInteger)lineIndex
                       pointIndex:(NSInteger)pointIndex;

/**
 * Callback method that gets invoked when the user taps on a chart bar.
 */
- (void)userClickedOnBarAtIndex:(NSInteger)barIndex;


- (void)userClickedOnPieIndexItem:(NSInteger)pieIndex;
- (void)didUnselectPieItem;
@end

#endif /* GANPieChartDelegate_h */
