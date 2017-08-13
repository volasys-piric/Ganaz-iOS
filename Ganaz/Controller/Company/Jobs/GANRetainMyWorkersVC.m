//
//  GANRetainMyWorkersVC.m
//  Ganaz
//
//  Created by forever on 8/7/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANRetainMyWorkersVC.h"
#import "GANCompanyAddWorkerVC.h"

#import "GANCompanyManager.h"

@interface GANRetainMyWorkersVC ()
@property (weak, nonatomic) IBOutlet UIButton *btnSendMessage;

@end

@implementation GANRetainMyWorkersVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self refreshView];
}

- (void) refreshView {
    self.btnSendMessage.layer.cornerRadius = 3.f;
    self.btnSendMessage.clipsToBounds = YES;
}

- (IBAction)onSendMessage:(id)sender {
    if([GANCompanyManager sharedInstance].arrMyWorkers.count == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
        GANCompanyAddWorkerVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_ADDWORKER"];
        vc.fromCustomVC = ENUM_COMPANY_ADDWORKERS_FROM_RETAINMYWORKERS;
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    } else {
        [self.tabBarController setSelectedIndex:2];
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
