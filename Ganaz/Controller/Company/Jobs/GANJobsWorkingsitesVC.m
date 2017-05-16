//
//  GANJobsWorkingsitesVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANJobsWorkingsitesVC.h"
#import "GANWorkingSiteItemTVC.h"
#import "GANJobsWorkingsitesDetailsVC.h"

#import "GANJobManager.h"
#import "GANUtils.h"
#import "GANGenericFunctionManager.h"
#import "GANGlobalVCManager.h"
#import "Global.h"

@interface GANJobsWorkingsitesVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@end

@implementation GANJobsWorkingsitesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self registerTableViewCellFromNib];
    [self refreshViews];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableview reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) registerTableViewCellFromNib{
    [self.tableview registerNib:[UINib nibWithNibName:@"WorkingSiteItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_WORKINGSITE_ITEM"];
}

- (void) refreshViews{
    [self refreshTitle];
}

- (void) refreshTitle{
    self.lblTitle.text = [NSString stringWithFormat:@"Working sites (%d)", (int) [[GANJobManager sharedInstance].modelOnboardingJob.arrSite count]];
}

- (void) gotoSiteDetailsAtIndex: (int) index{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    GANJobsWorkingsitesDetailsVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_JOBS_WORKINGSITES_DETAILS"];
    vc.indexSite = index;
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) deleteSiteAtIndex: (int) index{
    [[GANJobManager sharedInstance].modelOnboardingJob.arrSite removeObjectAtIndex:index];
    [self.tableview reloadData];
}

- (void) promptForDeleteAtIndex: (int) index{
    dispatch_async(dispatch_get_main_queue(), ^{
        [GANGlobalVCManager promptWithVC:self Title:@"Confirmation" Message:@"Are you sure you want to delete?" ButtonYes:@"Yes" ButtonNo:@"No" CallbackYes:^{
            [self deleteSiteAtIndex:index];
        } CallbackNo:nil];
        [self.tableview setEditing:NO animated:YES];
    });
}

#pragma mark - UITableView Delegate

- (void) configureCell: (GANWorkingSiteItemTVC *) cell AtIndex: (int) index{
    GANLocationDataModel *site = [[GANJobManager sharedInstance].modelOnboardingJob.arrSite objectAtIndex:index];
    cell.lblAddress.text = site.szAddress;
    cell.viewContainer.layer.cornerRadius = 4;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[GANJobManager sharedInstance].modelOnboardingJob.arrSite count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GANWorkingSiteItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_WORKINGSITE_ITEM"];
    [self configureCell:cell AtIndex:(int) indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 66;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        [self promptForDeleteAtIndex:(int) indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self gotoSiteDetailsAtIndex:(int) indexPath.row];
}

#pragma mark - UIButton Delegate

- (IBAction)onBtnAddClick:(id)sender {
    [self gotoSiteDetailsAtIndex:-1];
}

@end
