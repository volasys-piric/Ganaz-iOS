//
//  GANCompanyMapPopupVC.m
//  Ganaz
//
//  Created by forever on 9/6/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyMapPopupVC.h"
#import "Global.h"

#import "GANGenericFunctionManager.h"

@interface GANCompanyMapPopupVC ()<GMSMapViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewContents;
@property (weak, nonatomic) IBOutlet UIView *viewMap;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnSelect;

@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) CLLocation *locationCenter;
@property (strong, nonatomic) NSString *szAddress;

@end

@implementation GANCompanyMapPopupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.locationCenter = [GANLocationManager sharedInstance].location;
    self.szAddress = [GANLocationManager sharedInstance].szAddress;
    
    [self refreshViews];
    [self buildMapView];

}

- (void) refreshViews {
    self.viewContents.clipsToBounds         = YES;
    self.viewContents.layer.cornerRadius    = 3;
    self.viewContents.layer.borderWidth     = 1;
    self.viewContents.layer.borderColor     = GANUICOLOR_THEMECOLOR_MAIN.CGColor;
    
    self.viewMap.clipsToBounds         = YES;
    self.viewMap.layer.cornerRadius    = 3;
    self.viewMap.layer.borderWidth     = 1;
    self.viewMap.layer.borderColor     = GANUICOLOR_THEMECOLOR_MAIN.CGColor;
    
    self.btnSelect.layer.cornerRadius = 3;
    self.btnSelect.clipsToBounds = YES;
    
    self.btnCancel.layer.cornerRadius = 3;
    self.btnCancel.clipsToBounds = YES;
}


#pragma mark - Biz Logic

- (void) requestAddress{
    GANLocationManager *managerLocation = [GANLocationManager sharedInstance];
    [managerLocation requestAddressWithLocation:self.locationCenter callback:^(NSString *szAddress) {
        self.szAddress = [GANGenericFunctionManager refineNSString:szAddress];
    }];
}

- (void) closeDialog{
    [UIView animateWithDuration:TRANSITION_FADEOUT_DURATION animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL b){
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

#pragma mark - GoogleMaps

- (void) buildMapView{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.locationCenter.coordinate.latitude
                                                                longitude:self.locationCenter.coordinate.longitude
                                                                     zoom:12];
        
        CGRect rcMapView = self.viewMap.frame;
        self.mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, rcMapView.size.width, rcMapView.size.height) camera:camera];
        self.mapView.myLocationEnabled = YES;
        self.mapView.delegate = self;
        [self.viewMap addSubview:self.mapView];
    });
}

-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
    self.locationCenter = [[CLLocation alloc]initWithLatitude:position.target.latitude longitude:position.target.longitude];
    [self requestAddress];
}

- (IBAction)onBtnWrapperClick:(id)sender {
    [self.view endEditing:YES];
    [self closeDialog];
}

- (IBAction)onSelect:(id)sender {
    
    GANLocationDataModel *site = [[GANLocationDataModel alloc] init];
    site.szAddress = self.szAddress;
    site.fLatitude = self.locationCenter.coordinate.latitude;
    site.fLongitude = self.locationCenter.coordinate.longitude;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(submitLocation:)]) {
        [self.delegate submitLocation:site];
    }
    
    [self.view endEditing:YES];
    [self closeDialog];
}

- (IBAction)onCancel:(id)sender {
    [self.view endEditing:YES];
    [self closeDialog];
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

@end
