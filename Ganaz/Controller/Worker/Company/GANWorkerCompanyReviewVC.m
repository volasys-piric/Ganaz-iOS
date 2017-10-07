//
//  GANWorkerCompanyReviewVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/26/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANWorkerCompanyReviewVC.h"
#import "GANWorkerCompanyReviewItemTVC.h"
#import "GANGenericFunctionManager.h"
#import "GANCacheManager.h"
#import "GANUserManager.h"
#import "GANReviewManager.h"
#import "GANGlobalVCManager.h"
#import "Global.h"
#import "GANAppManager.h"

@interface GANWorkerCompanyReviewVC () <UITableViewDelegate, UITableViewDataSource, GANWorkerCompanyReviewItemCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewComments;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UITextView *textviewComments;

@property (weak, nonatomic) IBOutlet UILabel *lblCompanyName;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTableviewHeight;

@property (strong, nonatomic) NSArray *arrItem;
@property (strong, nonatomic) GANCompanyDataModel *company;
@property (strong, nonatomic) GANReviewDataModel *review;
@property (assign, atomic) int indexReview;

@end

#define CONSTANT_TABLEVIEWCELL_HEIGHT               50

@implementation GANWorkerCompanyReviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.arrItem = @[];
    self.indexReview = -1;
    
    [self refreshFields];
    [self registerTableViewCellFromNib];
    [self refreshViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) registerTableViewCellFromNib{
    [self.tableview registerNib:[UINib nibWithNibName:@"WorkerCompanyReviewItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_WORKER_COMPANY_REVIEWITEM"];
}

- (void) refreshFields{
    self.company = [[GANCacheManager sharedInstance].arrayCompanies objectAtIndex:self.indexCompany];
    self.indexReview = [[GANReviewManager sharedInstance] getIndexForReviewByCompanyId:self.company.szId];
    if (self.indexReview == -1){
        self.review = [[GANReviewDataModel alloc] init];
    }
    else {
        self.review = [[GANReviewManager sharedInstance].arrReviews objectAtIndex:self.indexReview];
        self.textviewComments.text = self.review.szComments;
    }
    
    self.arrItem = @[@{@"icon": @"icon-review-pay", @"title": @"Pago"},
                     @{@"icon": @"icon-review-benefit", @"title": @"Beneficios"},
                     @{@"icon": @"icon-review-supervision", @"title": @"Supervisores"},
                     @{@"icon": @"icon-review-security", @"title": @"Salud y Seguridad"},
                     @{@"icon": @"icon-review-handshake", @"title": @"Honestidad"},
                     ];
}

- (void) refreshViews{
    self.viewComments.layer.cornerRadius = 3;
    self.btnSubmit.layer.cornerRadius = 3;
}

- (void) viewDidLayoutSubviews{
    self.constraintTableviewHeight.constant = CONSTANT_TABLEVIEWCELL_HEIGHT * [self.arrItem count];
    [self.view layoutIfNeeded];
}

#pragma mark - Biz Logic

- (BOOL) checkMandatoryFields{
    return YES;
}

- (void) doSubmitReview{
    if (self.indexReview != -1){
        // You already left your review on this company
        [GANGlobalVCManager showHudInfoWithMessage:@"Usted ya entregó su opinión sobre esta empresa." DismissAfter:-1 Callback:nil];
        return;
    }
    if ([self checkMandatoryFields] == NO) return;
    
    self.review.szCompanyId = self.company.szId;
    self.review.szWorkerUserId = [GANUserManager getUserWorkerDataModel].szId;
    self.review.szComments = self.textviewComments.text;
    
    // Please wait...
    [GANGlobalVCManager showHudProgressWithMessage:@"Por favor, espere..."];
    [[GANReviewManager sharedInstance] requestAddReview:self.review Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            // Your review is successfully submitted.
            [GANGlobalVCManager showHudSuccessWithMessage:@"Su opinión ha sido entregado sin su identificación del usuario." DismissAfter:-1 Callback:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        else {
            // Sorry, we've encountered an error.
            [GANGlobalVCManager showHudErrorWithMessage:@"Perdón. Hemos encontrado un error." DismissAfter:-1 Callback:nil];
        }
    }];
    GANACTIVITY_REPORT(@"Worker - Leave review");
}

#pragma mark - UITableView Delegate

- (void) configureCell: (GANWorkerCompanyReviewItemTVC *) cell AtIndex: (int) index{
    NSDictionary *dict = [self.arrItem objectAtIndex:index];
    NSString *szImage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"icon"]];
    NSString *szTitle = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"title"]];
    int value = [self.review getRatingAtIndex:index];
    
    cell.delegate = self;
    [cell updateViewsWithIndex:index Title:szTitle Image:szImage Value:value];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrItem count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GANWorkerCompanyReviewItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_WORKER_COMPANY_REVIEWITEM"];
    [self configureCell:cell AtIndex:(int) indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

#pragma mark - UIButton

- (IBAction)onBtnSubmitClick:(id)sender {
    [self.view endEditing:YES];
    [self doSubmitReview];
}

#pragma mark - Delegate

- (void)reviewItemCell:(GANWorkerCompanyReviewItemTVC *)cell Index:(int)indexCell onStarChanged:(int)star{
    [self.review setRating:star AtIndex:indexCell];
}

@end
