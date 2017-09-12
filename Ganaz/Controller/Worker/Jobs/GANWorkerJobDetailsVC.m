//
//  GANWorkerJobDetailsVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/25/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANWorkerJobDetailsVC.h"
#import "GANWorkerCompanyDetailsVC.h"
#import "GANWorkerBenefitItemTVC.h"
#import "GANWorkerBenefitItemCVC.h"
#import "GANWorkerJobApplyVC.h"

#import "GANLocationManager.h"
#import "GANCacheManager.h"
#import "GANUserCompanyDataModel.h"
#import "GANJobManager.h"
#import "GANJobDataModel.h"
#import "GANUserManager.h"
#import "GANDataManager.h"

#import "GANGlobalVCManager.h"
#import "GANFadeTransitionDelegate.h"
#import "GANBenefitInfoPopupVC.h"

#import "Global.h"
#import "GANGenericFunctionManager.h"
#import "GANAppManager.h"

@interface GANWorkerJobDetailsVC () </*UITableViewDelegate, UITableViewDataSource, */UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *viewBadge;
@property (weak, nonatomic) IBOutlet UIView *viewMapContainer;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionviewBenefits;
//@property (weak, nonatomic) IBOutlet UITableView *tableviewBenefits;
@property (weak, nonatomic) IBOutlet UIImageView *imgBadge;

@property (weak, nonatomic) IBOutlet UILabel *lblCompanyName;
@property (weak, nonatomic) IBOutlet UILabel *lblBadge;
@property (weak, nonatomic) IBOutlet UILabel *lblJobTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblUnit;
@property (weak, nonatomic) IBOutlet UILabel *lblPriceNA;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblPositions;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;

@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (weak, nonatomic) IBOutlet UIButton *btnApply;
@property (weak, nonatomic) IBOutlet UIButton *btnCompanyDetails;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintViewJobSummaryTopSpacing;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTableviewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintCollectionviewHeight;

@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) CLLocation *locationCenter;

@property (strong, nonatomic) NSMutableArray<GANBenefitDataModel *> *arrBenefit;

@property (strong, nonatomic) GANCompanyDataModel *company;
@property (strong, nonatomic) GANJobDataModel *job;

@property (strong, nonatomic) GANFadeTransitionDelegate *transController;
@property (assign, atomic) BOOL isRecruited;

@end

#define CONSTANT_TABLEVIEWCELL_HEIGHT               50
#define CONSTANT_BENEFIT_CONTENTS                   @"It won’t be a bigger problem to find one video game lover in your neighbor. Since the introduction of Virtual Game, it has been achieving great heights so far as its popularity and technological advancement are concerned. The history of video game is as interesting as a fairy tale."

@implementation GANWorkerJobDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.tableviewBenefits.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.tableviewBenefits.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.locationCenter = nil;
    
    self.arrBenefit = [[NSMutableArray alloc] init];
    
    self.transController = [[GANFadeTransitionDelegate alloc] init];
    
    [self refreshFields];
    [self registerCollectionViewCellFromNib];
//    [self registerTableViewCellFromNib];
    [self refreshViews];
    [self buildMapView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLocalNotificationReceived:)
                                                 name:nil
                                               object:nil];
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == YES){
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) registerCollectionViewCellFromNib{
    [self.collectionviewBenefits registerNib:[UINib nibWithNibName:@"WorkerBenefitItemCVC" bundle:nil] forCellWithReuseIdentifier:@"CVC_WORKER_BENEFITITEM"];
}

/*
- (void) registerTableViewCellFromNib{
    [self.tableviewBenefits registerNib:[UINib nibWithNibName:@"WorkerBenefitItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_WORKER_BENEFITITEM"];
}
*/

- (void) refreshOnChange{
    [self refreshFields];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addMapMarker];
//        [self.tableviewBenefits reloadData];
    });
}

- (void) refreshFields{
    self.company = [[GANCacheManager sharedInstance].arrCompanies objectAtIndex:self.indexCompany];
    self.job = [self.company.arrJobs objectAtIndex:self.indexJob];
    
    GANENUM_COMPANY_BADGE_TYPE enumType = [self.company getBadgeType];
    if (enumType == GANENUM_COMPANY_BADGE_TYPE_NONE){
        self.viewBadge.hidden = YES;
        self.constraintViewJobSummaryTopSpacing.constant = 14;
    }
    else if (enumType == GANENUM_COMPANY_BADGE_TYPE_SILVER){
        self.viewBadge.hidden = NO;
        self.constraintViewJobSummaryTopSpacing.constant = 64;
        self.viewBadge.layer.backgroundColor = GANUICOLOR_BADGE_SILVER.CGColor;
        self.lblBadge.text = @"EMPRESA PLATEADA";
    }
    else if (enumType == GANENUM_COMPANY_BADGE_TYPE_GOLD){
        self.viewBadge.hidden = NO;
        self.constraintViewJobSummaryTopSpacing.constant = 64;
        self.viewBadge.layer.backgroundColor = GANUICOLOR_BADGE_GOLD.CGColor;
        self.lblBadge.text = @"EMPRESA DORADA";
    }
    
    self.lblCompanyName.text = [self.company getBusinessNameES];
    self.lblJobTitle.text = [self.job getTitleES];
    self.navigationItem.title = [self.job getTitleES];
    
    self.lblPrice.text = [NSString stringWithFormat:@"$%.02f", self.job.fPayRate];
    self.lblDate.text = [NSString stringWithFormat:@"%@ - %@", [GANGenericFunctionManager getBeautifiedSpanishDate:self.job.dateFrom], [GANGenericFunctionManager getBeautifiedSpanishDate:self.job.dateTo]];
    self.lblUnit.text = self.job.szPayUnit; // == GANENUM_PAY_UNIT_HOUR) ? @"por hora" : @"por libra";
    self.lblPositions.text = [NSString stringWithFormat:@"%d puestos", self.job.nPositions];
    self.lblDescription.text = [self.job getCommentsES];
    
    if ([self.job isPayRateSpecified] == YES){
        self.lblPriceNA.hidden = YES;
        self.lblPrice.hidden = NO;
        self.lblUnit.hidden = NO;
    }
    else {
        self.lblPriceNA.hidden = NO;
        self.lblPrice.hidden = YES;
        self.lblUnit.hidden = YES;
    }
    
    [self.arrBenefit removeAllObjects];
    GANDataManager *managerData = [GANDataManager sharedInstance];
    
    if (self.job.isBenefitTraining == YES){
        [self.arrBenefit addObject:[managerData.arrBenefits objectAtIndex:0]];
    }
    if (self.job.isBenefitHealth == YES){
        [self.arrBenefit addObject:[managerData.arrBenefits objectAtIndex:1]];
    }
    if (self.job.isBenefitHousing == YES){
        [self.arrBenefit addObject:[managerData.arrBenefits objectAtIndex:2]];
    }
    if (self.job.isBenefitTransportation == YES){
        [self.arrBenefit addObject:[managerData.arrBenefits objectAtIndex:3]];
    }
    if (self.job.isBenefitBonus == YES){
        [self.arrBenefit addObject:[managerData.arrBenefits objectAtIndex:4]];
    }
    if (self.job.isBenefitScholarships == YES){
        [self.arrBenefit addObject:[managerData.arrBenefits objectAtIndex:5]];
    }
}

- (void) refreshViews{
    self.viewBadge.layer.cornerRadius = 2;
    self.btnApply.layer.cornerRadius = 3;
    self.btnShare.layer.cornerRadius = 3;
    self.btnCompanyDetails.layer.cornerRadius = 3;
    self.btnCompanyDetails.layer.borderWidth = 1;
    self.btnCompanyDetails.layer.borderColor = GANUICOLOR_UIBUTTON_DELETE_BORDERCOLOR.CGColor;
    
    self.btnShare.layer.borderWidth = 1;
    self.btnShare.layer.borderColor = GANUICOLOR_UIBUTTON_DELETE_BORDERCOLOR.CGColor;
    
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == YES){
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void) viewDidLayoutSubviews{
//    self.constraintTableviewHeight.constant = CONSTANT_TABLEVIEWCELL_HEIGHT * [self.arrBenefit count];
    [self.view layoutIfNeeded];
    
    NSInteger section = 0;
    NSInteger totalItemsInSection = [self.collectionviewBenefits numberOfItemsInSection:section];
    
    UIEdgeInsets collectionViewInset = UIEdgeInsetsMake(0, 0, 0, 0);    // Inset: 0 0  0 0
    
    CGFloat collectionViewWidth = CGRectGetWidth(self.collectionviewBenefits.frame) - collectionViewInset.left - collectionViewInset.right;
    CGFloat cellWidth = 40;
    CGFloat cellSpacing = 20;
    
    NSInteger totalItemsInRow = floor(((CGFloat)collectionViewWidth + cellSpacing) / (cellWidth + cellSpacing));
    NSInteger numberOfRows = ceil((CGFloat)totalItemsInSection / totalItemsInRow);
    self.constraintCollectionviewHeight.constant = (cellWidth + cellSpacing) * numberOfRows - cellSpacing;
    
}

- (void) buildMapView{
    self.locationCenter = [GANLocationManager sharedInstance].location;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.locationCenter.coordinate.latitude
                                                                longitude:self.locationCenter.coordinate.longitude
                                                                     zoom:12];
        
        CGRect rcMapView = self.viewMapContainer.frame;
        self.mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, rcMapView.size.width, rcMapView.size.height) camera:camera];
        self.mapView.myLocationEnabled = YES;
        [self.viewMapContainer addSubview:self.mapView];
        
        [self addMapMarker];
    });
}

- (void) addMapMarker{
    CLLocation *locationCurrent = [GANLocationManager sharedInstance].location;
    UIImage *imgPin = [UIImage imageNamed:@"map-pin"];
    
    [self.mapView clear];
    
    GANLocationDataModel *site = [self.job getNearestSite];
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(site.fLatitude, site.fLongitude);
        
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    marker.title = site.szAddress;
    marker.infoWindowAnchor = CGPointMake(0.5, 0);
    marker.map = self.mapView;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.icon = imgPin;
    marker.groundAnchor = CGPointMake(0.5, 1);
    
    CLLocationCoordinate2D firstLocation = marker.position;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:firstLocation coordinate:firstLocation];
    bounds = [bounds includingCoordinate:locationCurrent.coordinate];
    
    [self.mapView moveCamera:[GMSCameraUpdate fitBounds:bounds withEdgeInsets:UIEdgeInsetsMake(50.0f, 50.0f, 50.0f, 50.0f)]];
}

- (void) doApply{
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == NO){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_LOGIN_PHONE"];
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        return;
    }

    /*
    // Please wait...
    [GANGlobalVCManager showHudProgressWithMessage:@"Por favor, espere..."];
    [[GANJobManager sharedInstance] requestApplyForJob:self.job.szId Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager showHudSuccessWithMessage:@"Le empresa ha sido notificado sobre su interés." DismissAfter:-1 Callback:^{
            }];
        }
        else {
            // Sorry, we've encountered an error.
            [GANGlobalVCManager showHudErrorWithMessage:@"Perdón. Hemos encontrado un error." DismissAfter:-1 Callback:nil];
        }
    }];
    
    GANACTIVITY_REPORT(@"Worker - Apply for job");
     */
    [self gotoJobApplyVC];
}

- (void) doShare{
    NSString *szPay = @"";
    if ([self.job isPayRateSpecified] == YES){
        szPay = [NSString stringWithFormat:@", %@ %@", self.lblPrice.text, self.lblUnit.text];
    }
    
    NSString *message = [NSString stringWithFormat:@"Pensé que te interesaría este trabajo: %@, %@%@. Hay más información y más trabajo en la aplicación Ganaz", [self.company getBusinessNameES], [self.job getTitleES], szPay];
    
    
    NSURL *url = [NSURL URLWithString:GANURL_APPSTORE];
    NSArray *objShare = @[message, url];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objShare applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
    
    GANACTIVITY_REPORT(@"Worker - Share job via social network");
}

- (void) updateTranslatedDescription{
    self.lblDescription.text = [self.job getCommentsES];
}

- (void) showDlgForBenefitAtIndex: (int) index{
    GANBenefitDataModel *benefit = [self.arrBenefit objectAtIndex:index];
    int indexBenefit = [[GANDataManager sharedInstance] getIndexForBenefitsByName:benefit.szName];
    if (indexBenefit == -1) return;
    
    GANBenefitInfoPopupVC *vc = [[GANBenefitInfoPopupVC alloc] initWithNibName:@"BenefitInfoPopup" bundle:nil];
    vc.view.backgroundColor = [UIColor clearColor];
    vc.indexBenefit = indexBenefit;
    
    [vc refreshFields];
    
    [vc setTransitioningDelegate:self.transController];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:vc animated:YES completion:nil];
    GANACTIVITY_REPORT(@"Worker - View benefit details of job");
}

- (void) gotoCompanyDetailsVC{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Worker" bundle:nil];
    GANWorkerCompanyDetailsVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_COMPANYDETAILS"];
    vc.indexCompany = self.indexCompany;
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    GANACTIVITY_REPORT(@"Worker - Go to company details from job details");
}

- (void) gotoJobApplyVC{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Worker" bundle:nil];
        GANWorkerJobApplyVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_JOBDETAILS_APPLY"];
        vc.szJobId = self.job.szId;
        
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        GANACTIVITY_REPORT(@"Worker - Go to apply view from job details");        
    });
}

/*
#pragma mark - UITableView Delegate

- (void) configureCell: (GANWorkerBenefitItemTVC *) cell AtIndex: (int) index{
    GANBenefitDataModel *benefit = [self.arrBenefit objectAtIndex:index];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.lblTitle.text = [benefit getTitleES];
    [cell.imgIcon setImage:[UIImage imageNamed:benefit.szIcon]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrBenefit count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GANWorkerBenefitItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_WORKER_BENEFITITEM"];
    [self configureCell:cell AtIndex:(int) indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CONSTANT_TABLEVIEWCELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int index = (int) indexPath.row;
    [self showDlgForBenefitAtIndex:index];
}
*/

#pragma mark - UICollectionView Delegate

- (void) configureCell: (GANWorkerBenefitItemCVC *) cell AtIndex: (int) index{
    GANBenefitDataModel *benefit = [self.arrBenefit objectAtIndex:index];
    [cell.imgIcon setImage:[UIImage imageNamed:benefit.szIcon]];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.arrBenefit count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GANWorkerBenefitItemCVC *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CVC_WORKER_BENEFITITEM" forIndexPath:indexPath];
    [self configureCell:cell AtIndex:(int) indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    int index = (int) indexPath.row;
    [self showDlgForBenefitAtIndex:index];
}

#pragma mark - UIButton Delegate

- (IBAction)onBtnShareClick:(id)sender {
    [self doShare];
}

- (IBAction)onBtnApplyClick:(id)sender {
    [self doApply];
}

- (IBAction)onBtnLoginClick:(id)sender {
    [self.view endEditing:YES];
    
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == NO){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_LOGIN_PHONE"];
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        return;
    }
}

- (IBAction)onBtnCompanyDetails:(id)sender {
    [self gotoCompanyDetailsVC];
}

#pragma mark -NSNotification

- (void) onLocalNotificationReceived:(NSNotification *) notification{
    if ([[notification name] isEqualToString:GANLOCALNOTIFICATION_CONTENTS_TRANSLATED]){
        [self updateTranslatedDescription];
    }
}

@end
