//
//  GANWorkerJobApplyVC.m
//  Ganaz
//
//  Created by Piric Djordje on 7/16/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANWorkerJobApplyVC.h"
#import "GANWorkerJobSuggestFriendVC.h"
#import "GANWorkerJobApplyCompletedVC.h"

#import "GANJobManager.h"
#import "GANAppManager.h"
#import "GANGlobalVCManager.h"
#import "Global.h"

@interface GANWorkerJobApplyVC ()

@property (weak, nonatomic) IBOutlet UIButton *buttonApply;
@property (weak, nonatomic) IBOutlet UIButton *buttonSuggestFriend;

@end

@implementation GANWorkerJobApplyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self refreshViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshViews{
    self.buttonApply.clipsToBounds = YES;
    self.buttonApply.layer.cornerRadius = 3;
    self.buttonSuggestFriend.clipsToBounds = YES;
    self.buttonSuggestFriend.layer.cornerRadius = 3;
}

#pragma mark - Biz Logic

- (void) doApplyJob{
    // Please wait...
    [GANGlobalVCManager showHudProgressWithMessage:@"Por favor, espere..."];
    [[GANJobManager sharedInstance] requestApplyForJob:self.szJobId Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager showHudSuccessWithMessage:@"Le empresa ha sido notificado sobre su interés." DismissAfter:-1 Callback:^{
                [self gotoJobApplyCompletedVC];
            }];
        }
        else {
            // Sorry, we've encountered an error.
            [GANGlobalVCManager showHudErrorWithMessage:@"Perdón. Hemos encontrado un error." DismissAfter:-1 Callback:nil];
        }
    }];
    
    GANACTIVITY_REPORT(@"Worker - Apply for job");
}

- (void) gotoJobApplyCompletedVC{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Worker" bundle:nil];
        GANWorkerJobApplyCompletedVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_JOBDETAILS_APPLYCOMPLETED"];
        vc.szJobId = self.szJobId;
        vc.isSuggestFriend = NO;
        
        NSMutableArray *arrNewVCs = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
        [arrNewVCs removeLastObject];
        
        UIViewController *lastVC = [arrNewVCs lastObject];
        [arrNewVCs addObject:vc];
        
        lastVC.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationController setViewControllers:arrNewVCs animated:YES];
        
        GANACTIVITY_REPORT(@"Worker - Go to apply-completed view from job apply view");
    });
}

- (void) gotoSuggestFriendVC{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Worker" bundle:nil];
        GANWorkerJobSuggestFriendVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_JOBDETAILS_SUGGESTFRIEND"];
        vc.szJobId = self.szJobId;
        
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        GANACTIVITY_REPORT(@"Worker - Go to suggest-friend view from job apply view");
    });
}

#pragma mark - UIButton Event Listeners

- (IBAction)onButtonApplyClick:(id)sender {
    [self doApplyJob];
}

- (IBAction)onButtonSuggestFriendClick:(id)sender {
    [self gotoSuggestFriendVC];
}

@end
