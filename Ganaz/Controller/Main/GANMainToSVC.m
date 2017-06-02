//
//  GANMainToSVC.m
//  Ganaz
//
//  Created by Chris Lin on 6/1/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANMainToSVC.h"

@interface GANMainToSVC ()

@end

@implementation GANMainToSVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

@end
