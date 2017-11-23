//
//  GANCompanyCrewWorkersListVC.m
//  Ganaz
//
//  Created by Chris Lin on 11/23/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyCrewWorkersListVC.h"
#import "GANCompanyCrewWorkerItemTVC.h"

#import "GANCompanyManager.h"

#import "UIColor+GANColor.h"
#import "Global.h"
#import "GANGlobalVCManager.h"

@interface GANCompanyCrewWorkersListVC () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIButton *buttonDone;

@property (strong, nonatomic) GANCrewDataModel *modelCrew;
@property (strong, nonatomic) NSMutableArray <GANMyWorkerDataModel *> *arrayMembers;
@property (strong, nonatomic) NSMutableArray <NSNumber *> *arrayMembersSelected;

@end

@implementation GANCompanyCrewWorkersListVC

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
    [self refreshTableview];
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

- (void) registerTableViewCellFromNib{
    [self.tableview registerNib:[UINib nibWithNibName:@"CompanyCrewWorkerItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_COMPANYCREWWORKERITEM"];
}

- (void) refreshViews {
    self.buttonDone.layer.cornerRadius = 3;
    self.buttonDone.clipsToBounds = YES;
}

- (void) refreshTableview {
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    self.arrayMembers = [[NSMutableArray alloc] init];
    [self.arrayMembers addObjectsFromArray:[managerCompany getMembersListForCrew:self.modelCrew.szId]];
    [self.arrayMembers addObjectsFromArray:[managerCompany getNonCrewMembersList]];
    
    self.arrayMembersSelected = [[NSMutableArray alloc] init];
    for (GANMyWorkerDataModel *myWorker in self.arrayMembers) {
        if ([myWorker isMemberWithCrewId:self.modelCrew.szId] == YES) {
            [self.arrayMembersSelected addObject:@(YES)];
        }
        else {
            [self.arrayMembersSelected addObject:@(NO)];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableview reloadData];
    });
}

#pragma mark - Logic

- (void) updateMyWorkerAtIndex: (int) index IsMember: (BOOL) isMember {
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    GANMyWorkerDataModel *myWorker = [self.arrayMembers objectAtIndex:index];
    
    NSString *message = @"";
    if (isMember == YES) {
        message = [NSString stringWithFormat:@"Will you add %@ as a member of %@?", [myWorker getDisplayName], self.modelCrew.szTitle];
    }
    else {
        message = [NSString stringWithFormat:@"Will you remove %@ from %@?", [myWorker getDisplayName], self.modelCrew.szTitle];
    }
    
    [GANGlobalVCManager promptWithVC:self Title:@"Confirmation" Message:message ButtonYes:@"Yes" ButtonNo:@"No" CallbackYes:^{
        NSString *newCrewId = @"";
        if (isMember == YES) {
            newCrewId = self.modelCrew.szId;
        }
        
        [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
        [managerCompany requestUpdateMyWorkerCrewWithMyWorkerId:myWorker.szId CrewId:self.modelCrew.szId Callback:^(int status) {
            if (status == SUCCESS_WITH_NO_ERROR) {
                myWorker.szCrewId = newCrewId;
                [self.arrayMembersSelected replaceObjectAtIndex:index withObject:@(isMember)];
                
                [GANGlobalVCManager hideHudProgressWithCallback:^{
                    [self.tableview reloadData];
                }];
            }
            else {
                [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an error." DismissAfter:-1 Callback:nil];
            }
        }];
    } CallbackNo:nil];
}

#pragma mark - UITableView Delegate

- (void) configureCell: (GANCompanyCrewWorkerItemTVC *) cell AtIndex: (int) index{
    GANMyWorkerDataModel *member = [self.arrayMembers objectAtIndex:index];
    cell.labelName.text = [member getDisplayName];
    cell.index = index;
    
    BOOL isSelected = [[self.arrayMembersSelected objectAtIndex:index] boolValue];
    [cell setItemSelected:isSelected];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = (int) indexPath.row;
    BOOL isSelected = [[self.arrayMembersSelected objectAtIndex:index] boolValue];
    [self updateMyWorkerAtIndex:index IsMember:!isSelected];
}

#pragma mark - UIButton Event Listeners

- (IBAction)onButtonDoneClick:(id)sender {
}

@end
