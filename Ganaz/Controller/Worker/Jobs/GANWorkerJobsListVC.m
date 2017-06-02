//
//  GANWorkerJobsListVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/24/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANWorkerJobsListVC.h"
#import "GANWorkerJobListItemTVC.h"
#import "GANWorkerJobsListFilterVC.h"
#import "GANWorkerCompanyDetailsVC.h"
#import "GANGenericFunctionManager.h"
#import "GANLocationManager.h"
#import "GANJobManager.h"
#import "GANJobDataModel.h"
#import "GANCacheManager.h"
#import "GANUserManager.h"
#import "GANGlobalVCManager.h"
#import "Global.h"

@interface GANWorkerJobsListVC () <UITableViewDataSource, UITableViewDelegate, GMSMapViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIView *viewMapContainer;
@property (weak, nonatomic) IBOutlet UIView *viewFilterPanel;
@property (weak, nonatomic) IBOutlet UILabel *lblFilter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTableviewHeight;

@property (assign, atomic) float fDistance;
@property (strong, nonatomic) NSDate *dateFrom;

@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) CLLocation *locationCenter;
@property (strong, nonatomic) NSMutableArray<GMSMarker *> *arrMarkers;

@end

#define CONSTANT_TABLEVIEWCELL_HEIGHT               76

@implementation GANWorkerJobsListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.arrMarkers = [[NSMutableArray alloc] init];
    
    self.fDistance = -1;
    self.dateFrom = nil;
    
    [self registerTableViewCellFromNib];
    [self refreshViews];
    [self buildMapView];
    
    [self doSearchJobs];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLocalNotificationReceived:)
                                                 name:nil
                                               object:nil];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == YES){
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) registerTableViewCellFromNib{
    [self.tableview registerNib:[UINib nibWithNibName:@"WorkerJobListItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_WORKER_JOBLIST_ITEM"];
}

- (void) refreshViews{
    self.viewFilterPanel.layer.cornerRadius = 3;
}

- (void) buildMapView{
    self.locationCenter = [[GANUserManager sharedInstance] getCurrentLocation];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.locationCenter.coordinate.latitude
                                                                longitude:self.locationCenter.coordinate.longitude
                                                                     zoom:12];
        
        CGRect rcMapView = self.viewMapContainer.frame;
        self.mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, rcMapView.size.width, rcMapView.size.height) camera:camera];
        self.mapView.delegate = self;
        
        self.mapView.myLocationEnabled = YES;
        [self.viewMapContainer addSubview:self.mapView];
        
        [self addMapMarker];
    });
}

- (void) addMapMarker{
    [self.mapView clear];
    [self.arrMarkers removeAllObjects];

    NSArray *arrJobs = [GANJobManager sharedInstance].arrJobsSearchResult;
    if (arrJobs.count == 0) return;
    
    CLLocation *locationCurrent = [[GANUserManager sharedInstance] getCurrentLocation];
    UIImage *imgPin = [UIImage imageNamed:@"map-pin"];
    
    
    for (int i = 0; i < (int) [arrJobs count]; i++){
        GANJobDataModel *job = [arrJobs objectAtIndex:i];
        GANLocationDataModel *site = [job getNearestSite];
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(site.fLatitude, site.fLongitude);
        
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.title = [NSString stringWithFormat:@"%@, %d positions", [job getTitleES], job.nPositions];
        marker.infoWindowAnchor = CGPointMake(0.5, 0);
        marker.map = self.mapView;
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.icon = imgPin;
        marker.groundAnchor = CGPointMake(0.5, 1);
        
        [self.arrMarkers addObject:marker];
    }
    
    /*
    CLLocationCoordinate2D firstLocation = ((GMSMarker *)[self.arrMarkers firstObject]).position;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:firstLocation coordinate:firstLocation];
    
    for (GMSMarker *marker in self.arrMarkers) {
        bounds = [bounds includingCoordinate:marker.position];
    }
    bounds = [bounds includingCoordinate:locationCurrent.coordinate];
    */
    
    // Show the markers within 50 miles, or the nearest marker if no marker within 50 miles.
    
    CLLocationCoordinate2D firstLocation = locationCurrent.coordinate;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:firstLocation coordinate:firstLocation];
    
    for (int i = 0; i < (int) [self.arrMarkers count]; i++){
        GMSMarker *marker = [self.arrMarkers objectAtIndex:i];
        GANJobDataModel *job = [arrJobs objectAtIndex:i];
        if (i > 0 && [job getNearestDistance] > 50) break;
        
        bounds = [bounds includingCoordinate:marker.position];
    }
    [self.mapView moveCamera:[GMSCameraUpdate fitBounds:bounds withEdgeInsets:UIEdgeInsetsMake(50.0f, 50.0f, 50.0f, 50.0f)]];
}

- (void) viewDidLayoutSubviews{
    self.constraintTableviewHeight.constant = CONSTANT_TABLEVIEWCELL_HEIGHT * [[GANJobManager sharedInstance].arrJobsSearchResult count];
    [self.view layoutIfNeeded];
}

- (void) refreshJobList{
    self.constraintTableviewHeight.constant = CONSTANT_TABLEVIEWCELL_HEIGHT * [[GANJobManager sharedInstance].arrJobsSearchResult count];
    [self.view layoutIfNeeded];
    
    [self.tableview reloadData];
    [self addMapMarker];
}

#pragma mark - Biz Logic

- (void) doSearchJobs{
    // Please wait...
    [GANGlobalVCManager showHudProgressWithMessage:@"Por favor, espere..."];
    [[GANJobManager sharedInstance] requestSearchJobsNearbyWithDistance:self.fDistance Date:self.dateFrom Callback:^(int status) {
        [GANGlobalVCManager hideHudProgress];
        if (status == SUCCESS_WITH_NO_ERROR){
            [self refreshJobList];
        }
    }];
}

- (void) gotoFilterVC{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Worker" bundle:nil];
    GANWorkerJobsListFilterVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_JOBS_FILTER"];
    vc.fDistance = self.fDistance;
    vc.dateFrom = self.dateFrom;
    
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) prepareGotoCompanyDetailsAtIndex: (int) index{
    GANJobDataModel *job = [[GANJobManager sharedInstance].arrJobsSearchResult objectAtIndex:index];
    // Please wait...
    [GANGlobalVCManager showHudProgressWithMessage:@"Por favor, espere..."];
    [[GANCacheManager sharedInstance] requestGetCompanyDetailsByCompanyId:job.szCompanyId Callback:^(int index) {
        [GANGlobalVCManager hideHudProgress];
        if (index != -1){
            [self gotoCompanyDetailsAtCompanyIndex:index];
        }
    }];
}

- (void) gotoCompanyDetailsAtCompanyIndex: (int) indexCompany{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Worker" bundle:nil];
    GANWorkerCompanyDetailsVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_COMPANYDETAILS"];
    vc.indexCompany = indexCompany;
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark - UITableView Delegate

- (void) configureCell: (GANWorkerJobListItemTVC *) cell AtIndex: (int) index{
    GANJobDataModel *job = [[GANJobManager sharedInstance].arrJobsSearchResult objectAtIndex:index];
    cell.lblTitle.text = [job getTitleES];
    cell.lblCompany.text = @"";
    [[GANCacheManager sharedInstance] getCompanyBusinessNameESByCompanyId:job.szCompanyId Callback:^(NSString *businessNameES) {
        cell.lblCompany.text = businessNameES;
    }];
    cell.lblDistance.text = [NSString stringWithFormat:@"%.2fmi", [job getNearestDistance]];
    cell.viewContainer.layer.cornerRadius = 4;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[GANJobManager sharedInstance].arrJobsSearchResult count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GANWorkerJobListItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_WORKER_JOBLIST_ITEM"];
    [self configureCell:cell AtIndex:(int) indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 76;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = (int) indexPath.row;
    
    [self prepareGotoCompanyDetailsAtIndex:index];
}

#pragma mark - UIButton

- (IBAction)onBtnFilterClick:(id)sender {
    [self.view endEditing:YES];
    [self gotoFilterVC];
}

- (IBAction)onBtnLoginClick:(id)sender {
    [self.view endEditing:YES];
    
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == NO){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_LOGIN"];
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        return;
    }
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{
    for (int i = 0; i < (int) [self.arrMarkers count]; i++){
        GMSMarker *m = [self.arrMarkers objectAtIndex:i];
        if (m == marker){
            [self prepareGotoCompanyDetailsAtIndex:i];
            return;
        }
    }
}

#pragma mark -NSNotification

- (void) onLocalNotificationReceived:(NSNotification *) notification{
    if ([[notification name] isEqualToString:GANLOCALNOTIFICATION_WORKER_JOBSEARCH_FILTER_UPDATED]){
        NSDictionary *dict = notification.userInfo;
        NSString *distance = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"distance"]];
        NSDate *dateFrom = [dict objectForKey:@"date_from"];
        
        if (distance.length == 0) {
            self.fDistance = -1;
        }
        else {
            self.fDistance = [distance floatValue];
        }
        
        if (dateFrom == nil || [dateFrom isKindOfClass:[NSNull class]] == YES){
            self.dateFrom = nil;
        }
        else {
            self.dateFrom = dateFrom;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self doSearchJobs];
        });
    }
}

@end
