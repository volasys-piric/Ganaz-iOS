//
//  GANJobsDetailsVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANJobsDetailsVC.h"
#import "GANCompanySignupVC.h"
#import "GANJobPostSuccessPopupVC.h"
#import "GANSharePostingWithContactsVC.h"
#import "GANJobsWorkingsitesVC.h"

#import "GANUserManager.h"
#import "GANJobManager.h"
#import "GANJobDataModel.h"
#import "GANCompanyManager.h"
#import "GANRecruitManager.h"
#import "GANFadeTransitionDelegate.h"
#import "GANGenericFunctionManager.h"
#import "GANLocationManager.h"

#import "GANGlobalVCManager.h"
#import "GANUtils.h"
#import "Global.h"
#import <UIView+Shake/UIView+Shake.h>
#import "GANAppManager.h"



typedef enum _ENUM_POPUPFOR{
    GANENUM_POPUPFOR_NONE,
    GANENUM_POPUPFOR_PAYUNIT,
    GANENUM_POPUPFOR_DATEFROM,
    GANENUM_POPUPFOR_DATETO,
}GANENUM_POPUPFOR;

typedef enum _ENUM_PAYUNIT{
    GANENUM_PAYUNIT_LB,
    GANENUM_PAYUNIT_HOUR,
}GANENUM_PAYUNIT;

typedef enum _ENUM_JOBPOSTTYPE{
    GANENUM_JOBPOSTONLY,
    GANENUM_JOBPOSTANDBROADCAST
}GANENUM_JOBPOSTTYPE;

@interface GANJobsDetailsVC () <UITextFieldDelegate, GMSMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, GANJobPostSuccessPopupDelegate>
{
//    ENUM_COMPANY_SIGNUP_FROM_CUSTOMVC fromCustomVC;
    GANENUM_JOBPOSTTYPE postType;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *viewTitle;
@property (weak, nonatomic) IBOutlet UIView *viewPrice;
@property (weak, nonatomic) IBOutlet UIView *viewUnit;
@property (weak, nonatomic) IBOutlet UIView *viewDateFrom;
@property (weak, nonatomic) IBOutlet UIView *viewDateTo;
@property (weak, nonatomic) IBOutlet UIView *viewPositions;
@property (weak, nonatomic) IBOutlet UIView *viewBenefitsTraining;
@property (weak, nonatomic) IBOutlet UIView *viewBenefitsHealth;
@property (weak, nonatomic) IBOutlet UIView *viewBenefitsHousing;
@property (weak, nonatomic) IBOutlet UIView *viewBenefitsTransportation;
@property (weak, nonatomic) IBOutlet UIView *viewBenefitsBonus;
@property (weak, nonatomic) IBOutlet UIView *viewBenefitsScholarships;
@property (weak, nonatomic) IBOutlet UIView *viewMapContainer;
@property (weak, nonatomic) IBOutlet UIView *viewMapMaskEmpty;

@property (weak, nonatomic) IBOutlet UIView *viewComments;
@property (weak, nonatomic) IBOutlet UIView *viewPopupWrapper;
@property (weak, nonatomic) IBOutlet UIView *viewPopupPanel;

@property (weak, nonatomic) IBOutlet UITextField *txtTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtPrice;
@property (weak, nonatomic) IBOutlet UITextField *txtPositions;
@property (weak, nonatomic) IBOutlet UITextView *textviewComments;

@property (weak, nonatomic) IBOutlet UIButton *btnUnit;
@property (weak, nonatomic) IBOutlet UIButton *btnDateFrom;
@property (weak, nonatomic) IBOutlet UIButton *btnDateTo;
@property (weak, nonatomic) IBOutlet UIButton *btnBenefitsTraining;
@property (weak, nonatomic) IBOutlet UIButton *btnBenefitsHealth;
@property (weak, nonatomic) IBOutlet UIButton *btnBenefitsHousing;
@property (weak, nonatomic) IBOutlet UIButton *btnBenefitsTransportation;
@property (weak, nonatomic) IBOutlet UIButton *btnBenefitsBonus;
@property (weak, nonatomic) IBOutlet UIButton *btnBenefitsScholarships;
@property (weak, nonatomic) IBOutlet UIButton *btnAutoTranslate;
@property (weak, nonatomic) IBOutlet UIButton *btnPost;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
@property (weak, nonatomic) IBOutlet UIButton *btnPopupWrapper;
@property (weak, nonatomic) IBOutlet UIButton *btnPostwithBroadcast;

@property (weak, nonatomic) IBOutlet UILabel *lblWorkerCount;
@property (weak, nonatomic) IBOutlet UILabel *lblDateFrom;
@property (weak, nonatomic) IBOutlet UILabel *lblDateTo;
@property (weak, nonatomic) IBOutlet UILabel *lblBenefitsDotTraining;
@property (weak, nonatomic) IBOutlet UILabel *lblBenefitsDotHealth;
@property (weak, nonatomic) IBOutlet UILabel *lblBenefitsDotHousing;
@property (weak, nonatomic) IBOutlet UILabel *lblBenefitsDotTransportation;
@property (weak, nonatomic) IBOutlet UILabel *lblBenefitsDotBonus;
@property (weak, nonatomic) IBOutlet UILabel *lblBenefitsDotScholarships;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPopupBottomSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBtnSaveBottomSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintlblWorkerCount;

@property (strong, nonatomic) NSMutableArray *arrBenefit;
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) CLLocation *locationCenter;

@property (assign, atomic) GANENUM_POPUPFOR enumPopupFor;
@property (assign, atomic) GANENUM_PAY_UNIT enumPayUnit;
@property (strong, nonatomic) NSDate *dateFrom;
@property (strong, nonatomic) NSDate *dateTo;
@property (assign, atomic) BOOL isAutoTranslate;

@property (strong, nonatomic) GANFadeTransitionDelegate *transController;

@end

#define UICOLOR_BUTTON_NOTSELECTED                              [UIColor colorWithRed:(51 / 255.0) green:(51 / 255.0) blue:(51 / 255.0) alpha:0.6]
#define UICOLOR_LABELDOT_NOTSELECTED                            [UIColor colorWithRed:(203 / 255.0) green:(203 / 255.0) blue:(203 / 255.0) alpha:1]
#define UICOLOR_BUTTON_BACKGROUND_NOTSELECTED                   [UIColor colorWithRed:(51 / 255.0) green:(51 / 255.0) blue:(51 / 255.0) alpha:0.07]

#define UICOLOR_BUTTON_SELECTED                                 [UIColor colorWithRed:(255 / 255.0) green:(255 / 255.0) blue:(255 / 255.0) alpha:1]
#define UICOLOR_LABELDOT_SELECTED                               [UIColor colorWithRed:(255 / 255.0) green:(255 / 255.0) blue:(255 / 255.0) alpha:1]
#define UICOLOR_BUTTON_BACKGROUND_SELECTED                      [UIColor colorWithRed:(100 / 255.0) green:(179 / 255.0) blue:(31 / 255.0) alpha:1]

@implementation GANJobsDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.arrBenefit = [[NSMutableArray alloc] init];
    for (int i = 0; i < 6; i++){
        [self.arrBenefit addObject:@(NO)];
    }
    
    self.enumPopupFor = GANENUM_POPUPFOR_NONE;
    self.enumPayUnit = GANENUM_PAY_UNIT_HOUR;
    self.dateFrom = nil;
    self.dateTo = nil;
    self.datePicker.minimumDate = [NSDate date];
    self.isAutoTranslate = NO;
    self.locationCenter = nil;
    
    postType = GANENUM_JOBPOSTONLY;
//    fromCustomVC = ENUM_DEFAULT_SIGNUP;
    self.transController = [[GANFadeTransitionDelegate alloc] init];
    
    [self refreshFields];
    [self refreshViews];
    [self buildMapView];
    
    if (self.indexJob == -1){
        self.navigationItem.title = @"Add New Job";
    }
    else {
        self.navigationItem.title = @"Job Details";
    }
    
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(self.bPostedNewJob == YES) {
        [self CompletedUserSignup];
        return;
    }
    
    [self addMapMarker];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) refreshViews{
    self.viewTitle.layer.cornerRadius = 3;
    self.viewPrice.layer.cornerRadius = 3;
    self.viewUnit.layer.cornerRadius = 3;
    self.viewDateFrom.layer.cornerRadius = 3;
    self.viewDateTo.layer.cornerRadius = 3;
    self.viewPositions.layer.cornerRadius = 3;
    self.viewBenefitsTraining.layer.cornerRadius = 3;
    self.viewBenefitsHealth.layer.cornerRadius = 3;
    self.viewBenefitsHousing.layer.cornerRadius = 3;
    self.viewBenefitsTransportation.layer.cornerRadius = 3;
    self.viewBenefitsBonus.layer.cornerRadius = 3;
    self.viewBenefitsScholarships.layer.cornerRadius = 3;
    self.viewMapContainer.layer.cornerRadius = 3;
    self.viewComments.layer.cornerRadius = 3;
    
    self.btnPost.layer.cornerRadius = 3;
    self.btnPostwithBroadcast.layer.cornerRadius = 3;
    self.btnPostwithBroadcast.titleLabel.numberOfLines   = 2;
    self.btnPostwithBroadcast.titleLabel.textAlignment   = NSTextAlignmentCenter;
    self.btnDelete.layer.cornerRadius = 3;
    self.btnDelete.layer.borderWidth = 1;
    self.btnDelete.layer.borderColor = GANUICOLOR_UIBUTTON_DELETE_BORDERCOLOR.CGColor;
    
    if (self.indexJob == -1){
        [self.btnPost setTitle:@"Post Job" forState:UIControlStateNormal];
        self.constraintBtnSaveBottomSpace.constant = 94;
        self.btnDelete.hidden = YES;
        self.btnPostwithBroadcast.hidden = NO;
    }
    else {
        [self.btnPost setTitle:@"Update Job" forState:UIControlStateNormal];
        self.constraintBtnSaveBottomSpace.constant = 94;
        self.btnDelete.hidden = NO;
        self.btnPostwithBroadcast.hidden = YES;
    }
    
    //Test Code, It should be changed to 20 in Live version.
    if([[GANUserManager sharedInstance] getNearbyWorkerCount] <= 2) {
        self.constraintlblWorkerCount.constant = -58;
        [self.lblWorkerCount setHidden:YES];
    } else {
        self.lblWorkerCount.text = [NSString stringWithFormat:@"Super! There are %ld workers near you. Tell us about your job.", (long)[[GANUserManager sharedInstance] getNearbyWorkerCount]];
        [self.lblWorkerCount setHidden:NO];
    }
    
    [self refreshDateFields];
    [self refreshBenefitsPanel];
    [self refreshPopupPanel];
    [self refreshPickerView];
    [self refreshAutoTranslateView];
}

- (NSString *) getTextviewCommentsPlaceholderText{
    return @"This is a good place to say more about any benefits, job requirements, shift hours and any other info about what makes your company a great place to work.";
}

- (NSString *) getFinalCommentsText {
    if([self.textviewComments.text isEqualToString:[self getTextviewCommentsPlaceholderText]]) {
        return @"";
    } else {
        return self.textviewComments.text;
    }
}

- (void) refreshFields{
    self.textviewComments.text = [self getTextviewCommentsPlaceholderText];
    self.textviewComments.textColor = [UIColor lightGrayColor];
    
    if (self.indexJob == -1) return;
    
    GANJobManager *managerJob = [GANJobManager sharedInstance];
    GANJobDataModel *job = [managerJob.arrMyJobs objectAtIndex:self.indexJob];
    
    self.txtTitle.text = [job getTitleEN];
    self.txtPrice.text = [NSString stringWithFormat:@"%.2f", job.fPayRate];
    if ([job isPayRateSpecified] == NO){
        self.txtPrice.text = @"";
    }
    
    self.enumPayUnit = job.enumPayUnit;
    self.dateFrom = job.dateFrom;
    self.dateTo = job.dateTo;
    self.txtPositions.text = [NSString stringWithFormat:@"%d", job.nPositions];
    
    NSArray *arrBenefit = @[@(job.isBenefitTraining),
                            @(job.isBenefitHealth),
                            @(job.isBenefitHousing),
                            @(job.isBenefitTransportation),
                            @(job.isBenefitBonus),
                            @(job.isBenefitScholarships),
                            ];
    self.arrBenefit = [NSMutableArray arrayWithArray:arrBenefit];
    
    self.textviewComments.text = [job getCommentsEN];
    self.isAutoTranslate = job.isAutoTranslate;
    
    if (self.textviewComments.text.length == 0){
        self.textviewComments.text = [self getTextviewCommentsPlaceholderText];
        self.textviewComments.textColor = [UIColor lightGrayColor];
    }
    else {
        self.textviewComments.textColor = [UIColor blackColor];
    }
}

- (void) refreshBenefitsPanel{
    NSArray *arrView = @[self.viewBenefitsTraining, self.viewBenefitsHealth, self.viewBenefitsHousing, self.viewBenefitsTransportation, self.viewBenefitsBonus, self.viewBenefitsScholarships];
    NSArray *arrButton = @[self.btnBenefitsTraining, self.btnBenefitsHealth, self.btnBenefitsHousing, self.btnBenefitsTransportation, self.btnBenefitsBonus, self.btnBenefitsScholarships];
    NSArray *arrLabelDot = @[self.lblBenefitsDotTraining, self.lblBenefitsDotHealth, self.lblBenefitsDotHousing, self.lblBenefitsDotTransportation, self.lblBenefitsDotBonus, self.lblBenefitsDotScholarships];
    
    for (int i = 0; i < 6; i++){
        BOOL isSelected = [[self.arrBenefit objectAtIndex:i] boolValue];
        UIView *view = [arrView objectAtIndex:i];
        UIButton *button = [arrButton objectAtIndex:i];
        UILabel *labelDot = [arrLabelDot objectAtIndex:i];
        
        if (isSelected){
            view.layer.backgroundColor = UICOLOR_BUTTON_BACKGROUND_SELECTED.CGColor;
            [button setTitleColor:UICOLOR_BUTTON_SELECTED forState:UIControlStateNormal];
            labelDot.layer.backgroundColor = UICOLOR_LABELDOT_SELECTED.CGColor;
        }
        else {
            view.layer.backgroundColor = UICOLOR_BUTTON_BACKGROUND_NOTSELECTED.CGColor;
            [button setTitleColor:UICOLOR_BUTTON_NOTSELECTED forState:UIControlStateNormal];
            labelDot.layer.backgroundColor = UICOLOR_LABELDOT_NOTSELECTED.CGColor;
        }
        labelDot.layer.cornerRadius = 3;
        labelDot.clipsToBounds = YES;
    }
}

- (void) refreshPopupPanel{
    if (self.enumPopupFor == GANENUM_POPUPFOR_NONE){
        self.viewPopupWrapper.hidden = YES;
    }
    else {
        self.viewPopupWrapper.hidden = NO;
    }
}

- (void) refreshPickerView{
    if (self.enumPayUnit == GANENUM_PAY_UNIT_HOUR){
        [self.pickerView selectRow:1 inComponent:0 animated:NO];
    }
    else {
        [self.pickerView selectRow:0 inComponent:0 animated:NO];
    }
}

- (void) refreshAutoTranslateView{
    if (self.isAutoTranslate == YES){
        [self.btnAutoTranslate setImage:[UIImage imageNamed:@"icon-checked"] forState:UIControlStateNormal];
    }
    else {
        [self.btnAutoTranslate setImage:[UIImage imageNamed:@"icon-unchecked"] forState:UIControlStateNormal];
    }
}

- (void) refreshDateFields{
    if (self.dateFrom == nil){
        self.lblDateFrom.text = @"";
        [self.btnDateFrom setTitle:@"" forState:UIControlStateNormal];
    }
    else {
        self.lblDateFrom.text = [GANGenericFunctionManager getBeautifiedDate:self.dateFrom];
    }
    
    if (self.dateTo == nil){
        self.lblDateTo.text = @"";
    }
    else {
        self.lblDateTo.text = [GANGenericFunctionManager getBeautifiedDate:self.dateTo];
    }
}

- (void) refreshPayUnitField{
    if (self.enumPayUnit == GANENUM_PAY_UNIT_HOUR){
        [self.btnUnit setTitle:@"Hour" forState:UIControlStateNormal];
    }
    else {
        [self.btnUnit setTitle:@"Lb" forState:UIControlStateNormal];
    }
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
        self.mapView.delegate = self;
        [self.viewMapContainer addSubview:self.mapView];
        
        [self addMapMarker];
    });
}

- (void) addMapMarker{
    NSArray *arrSite = [GANJobManager sharedInstance].modelOnboardingJob.arrSite;
    if ([arrSite count] == 0){
        self.viewMapMaskEmpty.hidden = NO;
        return;
    }
    else {
        self.viewMapMaskEmpty.hidden = YES;
    }
    
    NSMutableArray *arrMarker = [[NSMutableArray alloc] init];
    UIImage *imgPin = [UIImage imageNamed:@"map-pin"];
    
    [self.mapView clear];
    
    for (int i = 0; i < (int) [arrSite count]; i++){
        GANLocationDataModel *site = [arrSite objectAtIndex:i];
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(site.fLatitude, site.fLongitude);
        
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.title = site.szAddress;
        marker.infoWindowAnchor = CGPointMake(0.5, 0);
        marker.map = self.mapView;
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.icon = imgPin;
        marker.groundAnchor = CGPointMake(0.5, 1);
        [arrMarker addObject:marker];
    }
    
    CLLocationCoordinate2D firstLocation = ((GMSMarker *)[arrMarker firstObject]).position;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:firstLocation coordinate:firstLocation];
    
    for (GMSMarker *marker in arrMarker) {
        bounds = [bounds includingCoordinate:marker.position];
    }
    
    CLLocation *locationCurrent = [GANLocationManager sharedInstance].location;
    bounds = [bounds includingCoordinate:locationCurrent.coordinate];
    
    [self.mapView moveCamera:[GMSCameraUpdate fitBounds:bounds withEdgeInsets:UIEdgeInsetsMake(50.0f, 50.0f, 50.0f, 50.0f)]];
}

#pragma mark - UI Stuff

- (void) moveMapToCenter{
    GMSCameraPosition *cameraPos = [GMSCameraPosition cameraWithLatitude:self.locationCenter.coordinate.latitude
                                                               longitude:self.locationCenter.coordinate.longitude
                                                                    zoom:12];
    
    [self.mapView animateToCameraPosition:cameraPos];
    [self.mapView animateToLocation:self.locationCenter.coordinate];
}

- (void) shakeInvalidFields: (UIView *) viewContainer{
    CGRect rc = viewContainer.frame;
    CGPoint pt = rc.origin;
    pt.x = 0;
    pt.y -= 60;
    float maxOffsetY = self.scrollView.contentSize.height - self.scrollView.frame.size.height;
    pt.y = MIN(pt.y, maxOffsetY);
    
    [self.scrollView setContentOffset:pt animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [viewContainer shake:6 withDelta:8 speed:0.07];
    });
}

- (void) animateToShowPopup:(GANENUM_POPUPFOR) popupFor{
    if (self.enumPopupFor == popupFor) return;
    
    if (popupFor == GANENUM_POPUPFOR_PAYUNIT){
        self.pickerView.hidden = NO;
        self.datePicker.hidden = YES;
    }
    else if (popupFor == GANENUM_POPUPFOR_DATEFROM){
        self.pickerView.hidden = YES;
        self.datePicker.hidden = NO;
        if (self.dateFrom != nil){
            self.datePicker.date = self.dateFrom;
        }
        else {
            self.datePicker.date = [NSDate date];
        }
    }
    else if (popupFor == GANENUM_POPUPFOR_DATETO){
        self.pickerView.hidden = YES;
        self.datePicker.hidden = NO;
        if (self.dateTo != nil){
            self.datePicker.date = self.dateTo;
        }
        else {
            self.datePicker.date = [NSDate date];
        }
    }
    
    if (self.enumPopupFor != GANENUM_POPUPFOR_NONE){
        return;
    }
    
    // Animate to show
    
    self.enumPopupFor = popupFor;
    self.viewPopupWrapper.hidden = NO;
    self.viewPopupWrapper.alpha = 0;
    self.constraintPopupBottomSpace.constant = -250;
    [self.viewPopupWrapper layoutIfNeeded];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.constraintPopupBottomSpace.constant = 0;
        self.viewPopupWrapper.alpha = 1;
        [self.viewPopupWrapper layoutIfNeeded];
    }];
}

- (void) animateToHidePopup{
    if (self.viewPopupWrapper.hidden == YES) return;
    
    self.enumPopupFor = GANENUM_POPUPFOR_NONE;
    self.constraintPopupBottomSpace.constant = 0;
    self.viewPopupWrapper.alpha = 1;
    [self.viewPopupWrapper layoutIfNeeded];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.constraintPopupBottomSpace.constant = -250;
        self.viewPopupWrapper.alpha = 0;
        [self.viewPopupWrapper layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished == YES){
            self.viewPopupWrapper.hidden = YES;
        }
    }];
}

- (void) toggleBenefitsAtIndex: (int) index{
    BOOL isSelected = [[self.arrBenefit objectAtIndex:index] boolValue];
    [self.arrBenefit replaceObjectAtIndex:index withObject:@(!isSelected)];
    [self refreshBenefitsPanel];
}

#pragma mark - Biz Logic

- (BOOL) checkMandatoryFields{
    NSString *szTitle = self.txtTitle.text;
    NSString *szPositions = self.txtPositions.text;
    int positions = [szPositions intValue];
    
    if (szTitle.length == 0){
        [self shakeInvalidFields:self.viewTitle];
        return NO;
    }
    if (self.dateFrom == nil){
        [self shakeInvalidFields:self.viewDateFrom];
        return NO;
    }
    if (self.dateTo == nil){
        [self shakeInvalidFields:self.viewDateTo];
        return NO;
    }
    if ([self.dateTo compare:self.dateFrom] == NSOrderedAscending){
        [self shakeInvalidFields:self.viewDateTo];
        return NO;
    }
    
    if (positions == 0){
        [self shakeInvalidFields:self.viewPositions];
        return NO;
    }
    
    NSArray *arrSite = [GANJobManager sharedInstance].modelOnboardingJob.arrSite;
    if ([arrSite count] == 0){
        [GANGlobalVCManager showHudErrorWithMessage:@"Please add at least one working site" DismissAfter:-1 Callback:nil];
        return NO;
    }
    
    return YES;
}

- (void) preparePost{
    if ([self checkMandatoryFields] == NO) return;
    NSString *szTitle = self.txtTitle.text;
    NSString *szComments = [self getFinalCommentsText];
    __block NSString *szTitleTranslated = szTitle;
    __block NSString *szCommentsTranslated = szComments;
    BOOL shouldTranslate = self.isAutoTranslate;
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    __weak typeof(self) wSelf = self;
    
    [GANUtils requestTranslate:szComments Translate:shouldTranslate FromLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_EN ToLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_ES Callback:^(int status, NSString *translatedText) {
        if (status == SUCCESS_WITH_NO_ERROR) szCommentsTranslated = translatedText;
        [GANUtils requestTranslate:szTitle Translate:shouldTranslate FromLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_EN ToLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_ES Callback:^(int status, NSString *translatedText) {
            __strong typeof(self) sSelf = wSelf;
            if (status == SUCCESS_WITH_NO_ERROR) szTitleTranslated = translatedText;
            [sSelf doPostWithTranslatedTitle:szTitleTranslated TranslatedComments:szCommentsTranslated];
        }];
        
    }];
}

- (void) doPostWithTranslatedTitle: (NSString *) titleTranslated TranslatedComments: (NSString *) commentsTranslated{
    
    self.bPostedNewJob = NO;
    
    GANJobManager *managerJob = [GANJobManager sharedInstance];
    GANJobDataModel *job = managerJob.modelOnboardingJob;
    
    NSString *szTitle = self.txtTitle.text;
    float fPrice = [self.txtPrice.text floatValue];
    int nPos = [self.txtPositions.text intValue];
    NSString *szComments = [self getFinalCommentsText];
    
    job.szCompanyId = [GANUserManager getCompanyDataModel].szId;
    job.szCompanyUserId = [GANUserManager getUserCompanyDataModel].szId;
    job.modelTitle.szTextEN = szTitle;
    job.modelTitle.szTextES = titleTranslated;
    job.modelComments.szTextEN = szComments;
    job.modelComments.szTextES = commentsTranslated;
    job.isAutoTranslate = self.isAutoTranslate;

    job.fPayRate = fPrice;
    job.enumPayUnit = self.enumPayUnit;
    job.dateFrom = self.dateFrom;
    job.dateTo = self.dateTo;
    job.nPositions = nPos;
    job.enumFieldCondition = GANENUM_FIELDCONDITION_TYPE_GOOD;
    
    job.isBenefitTraining = [[self.arrBenefit objectAtIndex:0] boolValue];
    job.isBenefitHealth = [[self.arrBenefit objectAtIndex:1] boolValue];
    job.isBenefitHousing = [[self.arrBenefit objectAtIndex:2] boolValue];
    job.isBenefitTransportation = [[self.arrBenefit objectAtIndex:3] boolValue];
    job.isBenefitBonus = [[self.arrBenefit objectAtIndex:4] boolValue];
    job.isBenefitScholarships = [[self.arrBenefit objectAtIndex:5] boolValue];
    // Working site is already set
    
    if (self.indexJob == -1){
        [managerJob requestAddJob:job Callback:^(int status) {
            if (status == SUCCESS_WITH_NO_ERROR){
                
                if(postType == GANENUM_JOBPOSTANDBROADCAST) {
                    [self recruitWorkersToCurrentJob];
                } else {
                    [GANGlobalVCManager showHudSuccessWithMessage:@"Job has been created successfully" DismissAfter:3 Callback:^{
                        if([[GANCompanyManager sharedInstance].arrMyWorkers count] == 0) {
                            [self gotoSharePostWithContacts];
                        } else {
                            [GANGlobalVCManager tabBarController:self.tabBarController shouldSelectViewController:1];
                            [self.navigationController popToRootViewControllerAnimated:NO];
                        }
                        
                    }];
                }
                
            }
            else {
                [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue." DismissAfter:3 Callback:nil];
            }
        }];
        GANACTIVITY_REPORT(@"Company - Post new job");
    }
    else {
        [managerJob requestUpdateJobAtIndex:self.indexJob Job:job Callback:^(int status) {
            if (status == SUCCESS_WITH_NO_ERROR){
                [GANGlobalVCManager showHudSuccessWithMessage:@"Job has been updated successfully" DismissAfter:3 Callback:^{
                    [self gotoJobListVC];
                }];
            }
            else {
                [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue." DismissAfter:3 Callback:nil];
            }
        }];
        GANACTIVITY_REPORT(@"Company - Update job");
    }
}

- (void) recruitWorkersToCurrentJob {
    
    GANJobManager *managerJob = [GANJobManager sharedInstance];
    GANRecruitManager *managerRecruit = [GANRecruitManager sharedInstance];
    NSMutableArray *arrReRecruitUserIds = [[NSMutableArray alloc] init];
    
    float fBroadcast = GANNEARBY_DEFAULT_RADIUS;
    NSMutableArray *arrJobIds = [[NSMutableArray alloc] init];
    GANJobDataModel *job = [managerJob.arrMyJobs lastObject];
    [arrJobIds addObject:job.szId];
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    
    [managerRecruit requestSubmitRecruitWithJobIds:arrJobIds Broadcast:fBroadcast ReRecruitUserIds:arrReRecruitUserIds PhoneNumbers:nil Callback:^(int status, int count) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager hideHudProgress];
            [self showPopupDialog];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue." DismissAfter:-1 Callback:nil];
        }
        GANACTIVITY_REPORT(@"Company - Recruit");
    }];
}

- (void) doDelete{
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [[GANJobManager sharedInstance] requestDeleteJobAtIndex:self.indexJob Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager showHudSuccessWithMessage:@"Job has been deleted successfully" DismissAfter:3 Callback:^{
                [self gotoJobListVC];
            }];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue." DismissAfter:3 Callback:nil];
        }
    }];
    GANACTIVITY_REPORT(@"Company - Delete job from job details");
}

- (void) promptForDelete{
    [GANGlobalVCManager promptWithVC:self Title:@"Confirmation" Message:@"Are you sure you want to delete this?" ButtonYes:@"Yes" ButtonNo:@"No" CallbackYes:^{
        [self doDelete];
    } CallbackNo:nil];
}

-(void) showPopupDialog {
    
    if([[GANCompanyManager sharedInstance].arrMyWorkers count] == 0) {
        GANJobPostSuccessPopupVC *vc = [[GANJobPostSuccessPopupVC alloc] initWithNibName:@"GANJobPostSuccessPopupVC" bundle:nil];
        
        vc.delegate = self;
        vc.view.backgroundColor = [UIColor clearColor];
        [vc refreshFields:[[GANUserManager sharedInstance] getNearbyWorkerCount]];
        [vc setTransitioningDelegate:self.transController];
        vc.modalPresentationStyle = UIModalPresentationCustom;
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        [GANGlobalVCManager tabBarController:self.tabBarController shouldSelectViewController:1];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    
}

#pragma mark - GANJobPostSuccessPopupDelegate Method
- (void) didOK {
    [self gotoSharePostWithContacts];
}

- (void)gotoSharePostWithContacts {
    
    [GANGlobalVCManager tabBarController:self.tabBarController shouldSelectViewController:1];
    
    UINavigationController *navVC = [self.tabBarController selectedViewController];
    UIViewController *selectedVC = [navVC.viewControllers objectAtIndex:0];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    
    GANSharePostingWithContactsVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_JOBS_SHAREWITHWORKERS"];
    vc.fromVC = ENUM_COMPANY_SHAREPOSTINGWITHCONTACT_FROM_JOBPOST;
    [selectedVC.navigationController pushViewController:vc animated:YES];
    selectedVC.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void) gotoJobListVC{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) gotoManageWorkingSites{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    GANJobsWorkingsitesVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_JOBS_WORKINGSITES"];
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark - UIPickerView

- (IBAction)onDatePickerChanged:(id)sender {
    if (self.enumPopupFor == GANENUM_POPUPFOR_DATEFROM){
        self.dateFrom = self.datePicker.date;
    }
    else if (self.enumPopupFor == GANENUM_POPUPFOR_DATETO){
        self.dateTo = self.datePicker.date;
    }
    [self refreshDateFields];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (row == 0){
        self.enumPayUnit = GANENUM_PAY_UNIT_LB;
    }
    else {
        self.enumPayUnit = GANENUM_PAY_UNIT_HOUR;
    }
    [self refreshPayUnitField];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row == 0){
        return @"Lb";
    }
    return @"Hour";
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:[self getTextviewCommentsPlaceholderText]] == YES){
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

- (void) textViewDidEndEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@""] == YES){
        textView.text = [self getTextviewCommentsPlaceholderText];
        textView.textColor = [UIColor lightGrayColor];
    }
    [textView resignFirstResponder];
}

#pragma mark - UIButton Delegate

- (IBAction)onBtnUnitClick:(id)sender {
    [self.view endEditing:YES];
    [self animateToShowPopup:GANENUM_POPUPFOR_PAYUNIT];
}

- (IBAction)onBtnDateFromClick:(id)sender {
    [self.view endEditing:YES];
    [self animateToShowPopup:GANENUM_POPUPFOR_DATEFROM];
}

- (IBAction)onBtnDateToClick:(id)sender {
    [self.view endEditing:YES];
    [self animateToShowPopup:GANENUM_POPUPFOR_DATETO];
}

- (IBAction)btnBenefitsClick:(id)sender {
    [self.view endEditing:YES];
    UIButton *button = sender;
    int index = (int) button.tag;
    [self toggleBenefitsAtIndex:index];
}

- (IBAction)onBtnAutoTranslateClick:(id)sender {
    [self.view endEditing:YES];
    self.isAutoTranslate = !self.isAutoTranslate;
    [self refreshAutoTranslateView];
}

- (void) CompletedUserSignup {
    [self preparePost];
}

- (IBAction)onBtnPostClick:(id)sender {
    
    [self.view endEditing:YES];
    
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == NO){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
        GANCompanySignupVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_SIGNUP"];
        vc.fromCustomVC = ENUM_JOBPOST_SIGNUP;
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        return;
    }
    postType = GANENUM_JOBPOSTONLY;
    [self preparePost];
}

- (IBAction)onBtnDeleteClick:(id)sender {
    [self.view endEditing:YES];
    [self promptForDelete];
}

- (IBAction)onbtnPostwithBroadcase:(id)sender {
    [self.view endEditing:YES];
    
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == NO){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
        GANCompanySignupVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_SIGNUP"];
        vc.fromCustomVC = ENUM_JOBPOST_SIGNUP;
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        return;
    }
    
    postType = GANENUM_JOBPOSTANDBROADCAST;
    [self preparePost];
}

- (IBAction)onBtnPopupWrapperClick:(id)sender {
    [self.view endEditing:YES];
    [self animateToHidePopup];
}

- (IBAction)onBtnWorkingsitesManageClick:(id)sender {
    [self.view endEditing:YES];
    [self gotoManageWorkingSites];
}

- (IBAction)onBtnSaveClick:(id)sender {
    [self.view endEditing:YES];
    
}

@end
