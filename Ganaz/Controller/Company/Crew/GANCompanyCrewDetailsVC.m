//
//  GANCompanyCrewDetailsVC.m
//  Ganaz
//
//  Created by Chris Lin on 11/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyCrewDetailsVC.h"
#import "GANCompanyCrewWorkerItemTVC.h"
#import "GANCompanyCrewWorkersListVC.h"

#import "GANCompanyManager.h"

#import "UIColor+GANColor.h"
#import "Global.h"

@interface GANCompanyCrewDetailsVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *labelCrewName;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (weak, nonatomic) IBOutlet UIButton *buttonManageWorkers;
@property (weak, nonatomic) IBOutlet UIButton *buttonDeleteCrew;
@property (weak, nonatomic) IBOutlet UIButton *buttonSave;

@property (strong, nonatomic) GANCrewDataModel *modelCrew;
@property (strong, nonatomic) NSArray <GANMyWorkerDataModel *> *arrayMembers;

@end

@implementation GANCompanyCrewDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.modelCrew = [[GANCompanyManager sharedInstance].arrayCrews objectAtIndex:self.indexCrew];
    self.navigationItem.title = self.modelCrew.szTitle;
    
    [self refreshViews];
    [self registerTableViewCellFromNib];
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshTableview];
}

- (void) registerTableViewCellFromNib{
    [self.tableview registerNib:[UINib nibWithNibName:@"CompanyCrewWorkerItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_COMPANYCREWWORKERITEM"];
}

- (void) refreshViews {
    self.buttonManageWorkers.layer.cornerRadius = 3;
    self.buttonDeleteCrew.layer.cornerRadius = 3;
    self.buttonSave.layer.cornerRadius = 3;
    
    self.buttonManageWorkers.clipsToBounds = YES;
    self.buttonDeleteCrew.clipsToBounds = YES;
    self.buttonSave.clipsToBounds = YES;
    
    self.buttonDeleteCrew.layer.borderColor = [UIColor GANThemeMainColor].CGColor;
    self.buttonDeleteCrew.layer.borderWidth = 1;
    [self.buttonDeleteCrew setTitleColor:[UIColor GANThemeMainColor] forState:UIControlStateNormal];
    
    self.buttonManageWorkers.backgroundColor = [UIColor GANThemeGreenColor];
}

- (void) refreshTableview {
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    self.arrayMembers = [managerCompany getMembersListForCrew:self.modelCrew.szId];
    self.labelCrewName.text = self.modelCrew.szTitle;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableview reloadData];
    });
}

#pragma mark - Navigation

- (void) gotoCrewWorkersListVC{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CompanyCrew" bundle:nil];
        GANCompanyCrewWorkersListVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_CREW_WORKERSLIST"];
        vc.indexCrew = self.indexCrew;
        
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    });
}

#pragma mark - UITableView Delegate

- (void) configureCell: (GANCompanyCrewWorkerItemTVC *) cell AtIndex: (int) index{
    GANMyWorkerDataModel *member = [self.arrayMembers objectAtIndex:index];
    cell.labelName.text = [member getDisplayName];
    cell.index = index;
    [cell setItemSelected:YES];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrayMembers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GANCompanyCrewWorkerItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_COMPANYCREWWORKERITEM"];
    [self configureCell:cell AtIndex:(int) indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 53;
}

#pragma mark - UIButton Delegate

- (IBAction)onButtonManageWorkersClick:(id)sender {
    [self gotoCrewWorkersListVC];
}

- (IBAction)onButtonDeleteCrewClick:(id)sender {
}
- (IBAction)onButtonSaveClick:(id)sender {
}

@end
