//
//  GANWorkerUpdateLocaionVC.m
//  Ganaz
//
//  Created by Piric Djordje on 3/23/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANWorkerUpdateLocaionVC.h"
#import "GANUserManager.h"
#import "GANLocationManager.h"
#import "GANGenericFunctionManager.h"
#import "GANUtils.h"
#import "GANGlobalVCManager.h"
#import "Global.h"
#import "GANAppManager.h"

@interface GANWorkerUpdateLocaionVC () <GMSMapViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewAddressBar;
@property (weak, nonatomic) IBOutlet UIView *viewMapContainer;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;

@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) CLLocation *locationCenter;
@property (strong, nonatomic) NSString *szAddress;

@end

@implementation GANWorkerUpdateLocaionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.locationCenter = [[GANUserManager getUserWorkerDataModel].modelLocation generateCLLocation];
    self.szAddress = [GANUserManager getUserWorkerDataModel].modelLocation.szAddress;
    
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
    GANUserWorkerDataModel *me = [GANUserManager getUserWorkerDataModel];
    me.modelLocation.szAddress = self.szAddress;
    me.modelLocation.fLatitude = self.locationCenter.coordinate.latitude;
    me.modelLocation.fLongitude = self.locationCenter.coordinate.longitude;
    
    // Please wait...
    [GANGlobalVCManager showHudProgressWithMessage:@"Por favor, espere..."];
    [[GANUserManager sharedInstance] requestUpdateMyLocationWithCallback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager showHudSuccessWithMessage:@"Tu ubicación ha sido actualizado." DismissAfter:-1 Callback:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        else {
            // Sorry, we've encountered an error.
            [GANGlobalVCManager showHudErrorWithMessage:@"Perdón. Hemos encontrado un error." DismissAfter:-1 Callback:nil];
        }
    }];
    
    GANACTIVITY_REPORT(@"Worker - Update Location");
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
