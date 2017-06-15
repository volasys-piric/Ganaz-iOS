//
//  GANMainToSVC.m
//  Ganaz
//
//  Created by Chris Lin on 6/1/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANMainToSVC.h"

@interface GANMainToSVC ()

@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation GANMainToSVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Privacy-Policy" ofType:@"htm"]isDirectory:NO]]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

@end
