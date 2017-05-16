//
//  GANJobsWorkingsitesDetailsVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANJobsWorkingsitesDetailsVC.h"
#import "GANJobManager.h"
#import "GANLocationManager.h"
#import "GANGenericFunctionManager.h"
#import "GANUtils.h"

@interface GANJobsWorkingsitesDetailsVC () <GMSMapViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewAddressBar;
@property (weak, nonatomic) IBOutlet UIView *viewMapContainer;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;

@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) CLLocation *locationCenter;
@property (strong, nonatomic) NSString *szAddress;

@end

@implementation GANJobsWorkingsitesDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.indexSite == -1){
        self.locationCenter = [GANLocationManager sharedInstance].location;
        self.szAddress = [GANLocationManager sharedInstance].szAddress;
    }
    else {
        GANLocationDataModel *site = [[GANJobManager sharedInstance].modelOnboardingJob.arrSite objectAtIndex:self.indexSite];
        self.locationCenter = [[CLLocation alloc] initWithLatitude:site.fLatitude longitude:site.fLongitude];
        self.szAddress = site.szAddress;
    }
    
    [self buildMapView];
    [self refreshViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) refreshViews{
    self.viewAddressBar.layer.cornerRadius = 3;
}

#pragma mark - Biz Logic

- (void) requestAddress{
    GANLocationManager *managerLocation = [GANLocationManager sharedInstance];
    [managerLocation requestAddressWithLocation:self.locationCenter callback:^(NSString *szAddress) {
        self.szAddress = [GANGenericFunctionManager refineNSString:szAddress];
        if (self.szAddress.length > 0) self.txtAddress.text = self.szAddress;
    }];
}

- (void) saveAddress{
    GANLocationDataModel *site;
    if (self.indexSite == -1){
        site = [[GANLocationDataModel alloc] init];
        [[GANJobManager sharedInstance].modelOnboardingJob.arrSite addObject:site];
    }
    else{
        site = [[GANJobManager sharedInstance].modelOnboardingJob.arrSite objectAtIndex:self.indexSite];
    }
    site.szAddress = self.szAddress;
    site.fLatitude = self.locationCenter.coordinate.latitude;
    site.fLongitude = self.locationCenter.coordinate.longitude;
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - GoogleMaps

- (void) buildMapView{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.locationCenter.coordinate.latitude
                                                                longitude:self.locationCenter.coordinate.longitude
                                                                     zoom:12];
        
        CGRect rcMapView = self.viewMapContainer.frame;
        self.mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, rcMapView.size.width, rcMapView.size.height) camera:camera];
        self.mapView.myLocationEnabled = YES;
        self.mapView.delegate = self;
        [self.viewMapContainer addSubview:self.mapView];
        self.txtAddress.text = self.szAddress;
    });
}

-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
    self.locationCenter = [[CLLocation alloc]initWithLatitude:position.target.latitude longitude:position.target.longitude];
    [self requestAddress];
}

#pragma mark - UIButton Delegate

- (IBAction)onBtnSaveClick:(id)sender {
    [self saveAddress];
}

@end
