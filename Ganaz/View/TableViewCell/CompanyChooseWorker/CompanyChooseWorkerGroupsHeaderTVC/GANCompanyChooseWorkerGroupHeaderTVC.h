//
//  GANCompanyChooseWorkerGroupHeaderTVC.h
//  Ganaz
//
//  Created by Chris Lin on 4/20/18.
//  Copyright © 2018 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GANCompanyChooseWorkerGroupHeaderTVCDelegate <NSObject>

@optional

- (void) didAddGroupClick;

@end

@interface GANCompanyChooseWorkerGroupHeaderTVC : UITableViewCell

@property (weak, nonatomic) id<GANCompanyChooseWorkerGroupHeaderTVCDelegate> delegate;

- (float) getPreferredHeight;

@end
