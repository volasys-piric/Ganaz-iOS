//
//  GANLoginTosVC.m
//  Ganaz
//
//  Created by Piric Djordje on 6/1/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANLoginTosVC.h"
#import "GANGlobalVCManager.h"

@interface GANLoginTosVC () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (assign, atomic) BOOL isLoaded;

@end

@implementation GANLoginTosVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.webview.delegate = self;
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"privacy-policy" ofType:@"html"]isDirectory:NO]]];
    self.isLoaded = NO;
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.isLoaded = YES;
    [GANGlobalVCManager hideHudProgress];
}

#pragma mark - UIButton Delegate

- (IBAction)onBtnBackClick:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
