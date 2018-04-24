//
//  GANCompanyChooseWorkerHeaderTVC.h
//  Ganaz
//
//  Created by Chris Lin on 4/20/18.
//  Copyright © 2018 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GANCompanyChooseWorkerHeaderTVCDelegate <NSObject>

@optional

- (void) didAddWorkerClick;
- (void) didSelectAllClick;
- (void) didTextfieldSearchChange: (NSString *) text;

@end

@interface GANCompanyChooseWorkerHeaderTVC : UITableViewCell

@property (weak, nonatomic) id<GANCompanyChooseWorkerHeaderTVCDelegate> delegate;

- (void) refreshSelectAllButton: (BOOL) show SelectedAll: (BOOL) selectedAll;
- (float) getPreferredHeight;

@end
