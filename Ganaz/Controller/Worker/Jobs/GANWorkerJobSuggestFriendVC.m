//
//  GANWorkerJobSuggestFriendVC.m
//  Ganaz
//
//  Created by Piric Djordje on 7/16/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANWorkerJobSuggestFriendVC.h"
#import "GANWorkerSuggestFriendItemTVC.h"
#import "GANWorkerJobApplyCompletedVC.h"

#import "GANUserManager.h"
#import "GANCacheManager.h"
#import "GANPhonebookContactsManager.h"
#import "GANJobManager.h"
#import "GANGlobalVCManager.h"
#import "Global.h"
#import "GANAppManager.h"
#import "GANGenericFunctionManager.h"

@interface GANWorkerJobSuggestFriendVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewSearch;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (weak, nonatomic) IBOutlet UITextField *textfieldSearch;
@property (weak, nonatomic) IBOutlet UIButton *buttonSubmit;

@property (strong, nonatomic) NSMutableArray *arrFilteredContacts;
@property (assign, atomic) int indexSelected;

@end

@implementation GANWorkerJobSuggestFriendVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.indexSelected = -1;
    self.arrFilteredContacts = [[NSMutableArray alloc] init];
    
    [self refreshViews];
    [self registerTableViewCellFromNib];
    
    [self askPermissionForPhoneBook];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLocalNotificationReceived:)
                                                 name:GANLOCALNOTIFICATION_ONBOARDINGACTION_WORKER_SUGGESTFRIEND
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshViews{
    self.viewSearch.layer.cornerRadius = 3;
    self.viewSearch.clipsToBounds = YES;
    self.buttonSubmit.layer.cornerRadius = 3;
    self.buttonSubmit.clipsToBounds = YES;
}

- (void) registerTableViewCellFromNib{
    [self.tableview registerNib:[UINib nibWithNibName:@"WorkerSuggestFriendItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_WORKER_SUGGESTFRIEND"];
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Biz Logic

- (void) askPermissionForPhoneBook{
    [[GANPhonebookContactsManager sharedInstance] requestPermissionForAddressBookWithCallback:^(BOOL granted) {
        if (granted){
            [[GANPhonebookContactsManager sharedInstance] buildContactsList];
            [self buildFilteredArray];
        }
        else {
            // You will need to allow access to contacts later.
            [GANGlobalVCManager showAlertControllerWithVC:self Title:@"Ud. no ha permitido acceso" Message:@"Si quiere acceder sus contactos, habrá que ir a Configuración en su teléfono para permitirlo." Callback:nil];
        }
    }];
}

- (void) buildFilteredArray{
    self.indexSelected = -1;
    [self.arrFilteredContacts removeAllObjects];
    
    GANPhonebookContactsManager *managerPhonebook = [GANPhonebookContactsManager sharedInstance];
    if (managerPhonebook.isContactsListBuilt == NO){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableview reloadData];
        });
        return;
    }
    
    NSString *keyword = [self.textfieldSearch.text lowercaseString];
    keyword = [keyword stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    if (keyword.length == 0){
        [self.arrFilteredContacts addObjectsFromArray:managerPhonebook.arrContacts];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableview reloadData];
        });
        return;
    }
    
    for (int i = 0; i < (int) [managerPhonebook.arrContacts count]; i++){
        GANPhonebookContactDataModel *contact = [managerPhonebook.arrContacts objectAtIndex:i];
        NSString *sz = [NSString stringWithFormat:@"%@ %@ %@ %@", [contact getFullName], contact.modelPhone.szLocalNumber, [contact.modelPhone getBeautifiedPhoneNumber], contact.szEmail];
        sz = [sz lowercaseString];
        if ([sz rangeOfString:keyword].location != NSNotFound){
            [self.arrFilteredContacts addObject:contact];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableview reloadData];
    });
}

- (void) doSuggestFrield{
    if (self.indexSelected == -1 && [self.textfieldSearch.text isEqualToString:@""]){
        // Please select a contact
        [GANGlobalVCManager showHudErrorWithMessage:@"Por favor, elija un contacto" DismissAfter:-1 Callback:nil];
        return;
    }
    NSString *szPhoneFriendNumber;
    if(self.indexSelected == -1) {
        szPhoneFriendNumber = [GANGenericFunctionManager getValidPhoneNumber:self.textfieldSearch.text];
        if([szPhoneFriendNumber isEqualToString:@""]) {
            // Please enter a valid phone number
            [GANGlobalVCManager showHudErrorWithMessage:@"Por favor, entre un número de teléfono correcto (sin el “1”)" DismissAfter:-1 Callback:nil];
            [self.textfieldSearch becomeFirstResponder];
            return;
        }
    } else {
        GANPhonebookContactDataModel *contact = [self.arrFilteredContacts objectAtIndex:self.indexSelected];
        szPhoneFriendNumber = contact.modelPhone.szLocalNumber;
    }
    
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == NO){
        // Register onboarding action to CacheManager
        GANCacheManager *managerCache = [GANCacheManager sharedInstance];
        managerCache.modelOnboardingAction.enumLoginFrom = GANENUM_ONBOARDINGACTION_LOGINFROM_WORKER_SUGGESTFRIEND;
        managerCache.modelOnboardingAction.szJobId = self.szJobId;
        managerCache.modelOnboardingAction.szSugestPhoneNumber = szPhoneFriendNumber;
        
        // Go to Login VC
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_LOGIN_PHONE"];
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        return;
    }
    
    GANJobManager *managerJob = [GANJobManager sharedInstance];
    
    // Please wait...
    [GANGlobalVCManager showHudProgressWithMessage:@"Por favor, espere..."];
    
    [managerJob requestSuggestFriendForJob:self.szJobId PhoneNumber:szPhoneFriendNumber Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            // Your request has been sent...
            [GANGlobalVCManager showHudSuccessWithMessage:@"Gracias! Hemos notificado la empresa del interés de su amigo/a" DismissAfter:-1 Callback:^{
                [self gotoJobApplyCompletedVC];
            }];
        }
        else {
            // Sorry, we've encountered an issue
            [GANGlobalVCManager showHudErrorWithMessage:@"Perdón. Hemos encontrado un error." DismissAfter:-1 Callback:nil];
        }
    }];
    GANACTIVITY_REPORT(@"Worker - Suggest Friend for Job");
}

- (void) gotoJobApplyCompletedVC{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Worker" bundle:nil];
        GANWorkerJobApplyCompletedVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_JOBDETAILS_APPLYCOMPLETED"];
        vc.szJobId = self.szJobId;
        vc.isSuggestFriend = YES;
        
        NSMutableArray *arrNewVCs = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
        [arrNewVCs removeLastObject];
        [arrNewVCs removeLastObject];
        
        UIViewController *lastVC = [arrNewVCs lastObject];
        [arrNewVCs addObject:vc];
        
        lastVC.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationController setViewControllers:arrNewVCs animated:YES];
    });
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)onTextFieldSearchChanged:(id)sender {
    [self buildFilteredArray];
}

#pragma mark - UITableView Delegate

- (void) configureCell: (GANWorkerSuggestFriendItemTVC *) cell AtIndex: (int) index{
    GANPhonebookContactDataModel *contact = [self.arrFilteredContacts objectAtIndex:index];
    cell.labelName.text = [contact getFullName];
    cell.labelPhone.text = [contact.modelPhone getBeautifiedPhoneNumber];
    
    if (index == self.indexSelected){
        [cell.imageCheck setImage:[UIImage imageNamed:@"icon-checked"]];
    }
    else {
        [cell.imageCheck setImage:[UIImage imageNamed:@"icon-unchecked"]];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrFilteredContacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GANWorkerSuggestFriendItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_WORKER_SUGGESTFRIEND"];
    [self configureCell:cell AtIndex:(int) indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 63;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int index = (int) indexPath.row;
    self.indexSelected = index;
    [self.tableview reloadData];
}

#pragma mark - UIButton Event Listeners

- (IBAction)onButtonSubmitClick:(id)sender {
    [self.view endEditing:YES];
    [self doSuggestFrield];
}

#pragma mark -NSNotification

- (void) onLocalNotificationReceived:(NSNotification *) notification{
    if ([[notification name] isEqualToString:GANLOCALNOTIFICATION_ONBOARDINGACTION_WORKER_SUGGESTFRIEND]){
        [self doSuggestFrield];
    }
}

@end
