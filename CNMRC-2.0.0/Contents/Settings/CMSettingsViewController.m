//
//  CMSettingsViewController.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 17..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMSettingsViewController.h"
#import "CMSettingsCell.h"
#import "DQAlertView.h"
#import "CMSetAreaViewController.h"
#import "CMAuthAdultViewController.h"
#import "CMRCViewController.h"

@interface CMSettingsViewController ()

@end

@implementation CMSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
	// 제목.
	self.titleLabel.text = @"설정";
    
	// 백그라운드 컬러.
	self.view.backgroundColor = UIColorFromRGB(0xe5e5e5);
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	// 설정 정보(디스플레이용) 로드.
	self.settings = [self loadSettings];
    
	// 설정 정보(DB) 로드.
	self.setting = [[Setting all] objectAtIndex:0];
	[AppInfo resetSettings:self.setting];
	[self.settingsTable reloadData];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
	[self setSettingsTable:nil];
	[super viewDidUnload];
}

#pragma mark - 상속 메서드

// 완료.
- (IBAction)doneAction:(id)sender {
	[self.setting save];
	[self backAction:sender];
	[AppInfo resetSettings:self.setting];
}

#pragma mark - 프라이빗 메서드

// 설정 정보 로드.
- (NSMutableArray *)loadSettings {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
	return [[NSMutableArray alloc] initWithContentsOfFile:path];
}

// 모든 설정 초기화.
- (void)resetSetting {
	self.setting.isVibration = [NSNumber numberWithBool:NO];
	self.setting.isSound = [NSNumber numberWithBool:NO];
	self.setting.touchSensitivity = [NSNumber numberWithFloat:0.5];
	self.setting.isUpdateVODAlarm = [NSNumber numberWithBool:NO];
	self.setting.isWatchReservationAlarm = [NSNumber numberWithBool:NO];
	self.setting.isAutoAuthAdult = [NSNumber numberWithBool:NO];
    
	[self.setting save];
	[self.settingsTable reloadData];
	[AppInfo resetSettings:[[Setting all] objectAtIndex:0]];
}

- (IBAction)switchAction:(id)sender {
	UISwitch *settingsSwitch = (UISwitch *)sender;
    
	switch (settingsSwitch.tag) {
		case 0: // 진동 효과.
		{
			self.setting.isVibration = [NSNumber numberWithBool:settingsSwitch.on];
		}
            break;
            
		case 1: // 소리 효과.
		{
			self.setting.isSound = [NSNumber numberWithBool:settingsSwitch.on];
		}
            break;
            
		case 10: // VOD업데이트 알림.
		{
			self.setting.isUpdateVODAlarm = [NSNumber numberWithBool:settingsSwitch.on];
		}
            break;
            
		case 11: // 시청예약 알림.
		{
			self.setting.isWatchReservationAlarm = [NSNumber numberWithBool:settingsSwitch.on];
		}
            break;
            
		case 21: // 자동성인인증하기.
		{
			self.setting.isAutoAuthAdult = [NSNumber numberWithBool:settingsSwitch.on];
		}
            break;
            
		default:
			break;
	}
    
	[self.setting save];
}

- (IBAction)sliderAction:(id)sender {
	UISlider *slider = (UISlider *)sender;
	self.setting.touchSensitivity = [NSNumber numberWithFloat:slider.value];
	[self.setting save];
}

- (IBAction)initButtonAction:(id)sender {
    DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"알림"
                                                        message:@"모든 설정을 초기화하시겠습니까?"
                                              cancelButtonTitle:@"취소"
                                               otherButtonTitle:@"확인"];
    alertView.otherButtonAction = ^{
        Debug(@"OK Clicked");
        // 모든 설정 초기화.
        [self resetSetting];
    };
    
    [alertView show];
}

- (IBAction)settingButtonAction:(id)sender {
	CMRCViewController *viewController = (CMRCViewController *)CMAppDelegate.container.viewControllers[0];
	[viewController goSTBSettings];
}

- (IBAction)paringAction:(id)sender {
	CMRCViewController *viewController = (CMRCViewController *)CMAppDelegate.container.viewControllers[0];
	[viewController checkParing];
}

#pragma mark - 퍼블릭 메서드

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.settings.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [[self.settings objectAtIndex:section] objectForKey:@"title"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *subTitles = [[self.settings objectAtIndex:section] objectForKey:@"subTitles"];
	return [subTitles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	CMSettingsCell *cell = (CMSettingsCell *)[self cellWithTableView:tableView cellIdentifier:CellIdentifier nibName:@"CMSettingsCell"];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.backgroundColor = RGB(245, 245, 245);
    
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			cell.cellType = CMSettingsCellTypeSwitch;
			[cell.settingsSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
			cell.settingsSwitch.tag = indexPath.row;
			cell.settingsSwitch.on  = [self.setting.isVibration boolValue];
		}
		else if (indexPath.row == 1) {
			cell.cellType = CMSettingsCellTypeSwitch;
			[cell.settingsSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
			cell.settingsSwitch.tag = indexPath.row;
			cell.settingsSwitch.on  = [self.setting.isSound boolValue];
		}
		else {
			cell.cellType = CMSettingsCellTypeSlider;
			[cell.settingsSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
			cell.settingsSlider.tag = indexPath.row;
			cell.settingsSlider.value = [self.setting.touchSensitivity floatValue];
		}
	}
	else if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			cell.cellType = CMSettingsCellTypeSwitch;
			[cell.settingsSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
			cell.settingsSwitch.tag = 10 + indexPath.row;
			cell.settingsSwitch.on  = [self.setting.isUpdateVODAlarm boolValue];
		}
		else if (indexPath.row == 1) {
			cell.cellType = CMSettingsCellTypeSwitch;
			[cell.settingsSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
			cell.settingsSwitch.tag = 10 + indexPath.row;
			cell.settingsSwitch.on  = [self.setting.isWatchReservationAlarm boolValue];
		}
	}
	else if (indexPath.section == 2) {
		if (indexPath.row == 0) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
			cell.cellType = CMSettingsCellTypeLabel;
			cell.settingsLabel.text = AppInfo.isAdult ? @"인증 상태입니다." : @"미인증 상태입니다.";
		}
		else if (indexPath.row == 1) {
			cell.cellType = CMSettingsCellTypeSwitch;
			[cell.settingsSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
			cell.settingsSwitch.tag = 20 + indexPath.row;
			cell.settingsSwitch.on  = [self.setting.isAutoAuthAdult boolValue];
		}
	}
	else if (indexPath.section == 3) {
		if (indexPath.row == 0) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
			// !!!: 기본값은 송파/디지털기본형이다.
			cell.cellType = CMSettingsCellTypeLabel;
			cell.settingsLabel.text = [NSString stringWithFormat:@"%@/%@", self.setting.areaName, self.setting.productName];
		}
		else if (indexPath.row == 1) {
			cell.buttonTitle = @"초기화";
			cell.cellType = CMSettingsCellTypeButton;
			[cell.settingsButton addTarget:self action:@selector(initButtonAction:) forControlEvents:UIControlEventTouchUpInside];
			cell.settingsButton.tag = 30 + indexPath.row;
		}
		else if (indexPath.row == 2) {
			cell.buttonTitle = @"연결";
			cell.cellType = CMSettingsCellTypeButton;
			[cell.settingsButton addTarget:self action:@selector(paringAction:) forControlEvents:UIControlEventTouchUpInside];
			cell.settingsButton.tag = 30 + indexPath.row;
		}
	}
    
	// Configure the cell...
	NSString *subTitle = [[[[self.settings objectAtIndex:indexPath.section] objectForKey:@"subTitles"] objectAtIndex:indexPath.row] objectForKey:@"subTitle"];
	cell.textLabel.textColor = [UIColor grayColor];
	cell.textLabel.text = subTitle;
    
	return cell;
}

#pragma mark - Table view delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (section == 0 || section == 1 || section == 2) {
		UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width - 20, 30)];
		headerView.backgroundColor = [UIColor clearColor];
		UILabel *headerLabel = [[UILabel alloc] initWithFrame:headerView.frame];
		headerLabel.backgroundColor = [UIColor clearColor];
		headerLabel.textColor = UIColorFromRGB(0x7961aa);
		headerLabel.font = [UIFont boldSystemFontOfSize:17];
		headerLabel.text = [[self.settings objectAtIndex:section] objectForKey:@"title"];
		[headerView addSubview:headerLabel];
		return headerView;
	}
	return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (section == 2 && !AppInfo.isAutoAuthAdult) {
		UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 70)];
		footerView.backgroundColor = [UIColor clearColor];
		UILabel *footerLabel = [[UILabel alloc] initWithFrame:footerView.frame];
		footerLabel.backgroundColor = [UIColor clearColor];
		footerLabel.textAlignment = NSTextAlignmentCenter;
		footerLabel.textColor = UIColorFromRGB(0x7961aa);
		footerLabel.numberOfLines = 2;
		footerLabel.font = [UIFont boldSystemFontOfSize:14];
		footerLabel.text = @"자동성인인증으로 설정하시면\n인증절차없이 컨텐츠를 감상하실 수 있습니다.";
		[footerView addSubview:footerLabel];
		return footerView;
	}
    
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == 2 && !AppInfo.isAutoAuthAdult) {
		return 70.0;
	}
    
	return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 2) {
		if (indexPath.row == 0) {
			// 선택 컬러.
			CMSettingsCell *cell = (CMSettingsCell *)[tableView cellForRowAtIndexPath:indexPath];
			cell.backgroundColor = UIColorFromRGB(0xd7cfe1);
			cell.textLabel.textColor = [UIColor whiteColor];
			cell.settingsLabel.textColor = [UIColor whiteColor];
            
			// 성인인증.
			CMAuthAdultViewController *viewControlelr = [[CMAuthAdultViewController alloc] initWithNibName:@"CMAuthAdultViewController" bundle:nil];
			viewControlelr.menuType = CMMenuTypeAuthAdult;
			viewControlelr.authAdultViewType = CMAuthAdultViewTypeSettings;
			[self.navigationController pushViewController:viewControlelr animated:YES];
		}
	}
	else if (indexPath.section == 3) {
		if (indexPath.row == 0) {
			// 선택 컬러.
			CMSettingsCell *cell = (CMSettingsCell *)[tableView cellForRowAtIndexPath:indexPath];
			cell.backgroundColor = UIColorFromRGB(0xd7cfe1);
			cell.textLabel.textColor = [UIColor whiteColor];
			cell.settingsLabel.textColor = [UIColor whiteColor];
            
			// 지역설정.
			CMSetAreaViewController *viewControlelr = [[CMSetAreaViewController alloc] initWithNibName:@"CMSetAreaViewController" bundle:nil];
			[self.navigationController pushViewController:viewControlelr animated:YES];
		}
	}
}

@end
