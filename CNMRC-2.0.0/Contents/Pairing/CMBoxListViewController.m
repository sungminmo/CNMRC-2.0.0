//
//  CMBoxListViewController.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 24..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMBoxListViewController.h"

// 페어링 기본 포트.
const NSInteger kDefualtPairingPort = 9551;

@interface CMBoxListViewController ()
@property (strong, nonatomic) UITableViewCell *currentCell;

- (void)resetCell;
@end

@implementation CMBoxListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = @"셋탑박스 연결";
    
    // 테이블뷰 UI 설정.
    if (isiOS7)
    {
        self.boxTable.center = CGPointMake(self.boxTable.center.x, self.boxTable.center.y + 20.0);
    }
    self.boxTable.backgroundView = nil;
    self.boxTable.backgroundColor = UIColorFromRGB(0xe5e5e5);
    
    _finder = [[CMBoxFinder alloc] init];
    _finder.delegate = self;
    
    _delegate = RemoteManager;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [_finder searchForBoxes];
    
    if (self.currentCell)
    {
        [self resetCell];
    }
}

- (void)resetCell
{
    self.currentCell.backgroundColor = RGB(245, 245, 245);
    self.currentCell.textLabel.textColor = [UIColor darkGrayColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setBoxTable:nil];
    [super viewDidUnload];
}

#pragma mark - 퍼블릭 메서드

- (void)setAvailableBoxes:(NSArray *)availableBoxes
{
    NSAssert(0 == [availableBoxes count] ||
             [[availableBoxes lastObject] isKindOfClass:[CMBoxService class]],
             @"NSArray of BoxService expected.");
    if (_boxes != availableBoxes)
    {
        _boxes = availableBoxes;
    }
    
    [self.boxTable reloadData];
}

#pragma mark - 프라이빗 메서드

// IP 주소가 공인IP 인지 사설IP인지 체크한다.
- (BOOL)isPrivateAddress:(NSString *)address
{
    return [address hasPrefix:@"192"];
}

// 박스의 이름에서 IP를 가져온다.
// 예: stb_catv_cnm-192-168-0-131
- (NSString *)genAddress:(NSString *)boxName
{
    // 앞의 박스 이름을 제외하고 IP 부분만 가져온다.
    NSString *address = [boxName substringFromIndex:13];
    
    // "-"를 "."로 치환한다.
    return [address stringByReplacingOccurrencesOfString:@"-" withString:@"."];
}

#pragma mark - CMBoxFinderDelegate

// 박스가 발견되면 호출된다.
- (void)didChangeBoxList:(NSArray *)boxes
{
    Debug(@"Found box(es): %@", [boxes description]);
    [self setAvailableBoxes:boxes];
    [self.boxTable reloadData];
}

#pragma mark - CMSetIPViewControllerDelegate

- (void)setIPViewControllerDidEnd:(CMSetIPViewController *)controller
{
    NSArray *addresses = [NSArray arrayWithObject:[controller address]];
    CMBoxService *service = [[CMBoxService alloc] initWithAddresses:addresses
                                                               port:kDefualtPairingPort
                                                               name:@"ManuallyEnteredGTV"];
    [_delegate didSelectBox:service];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"구글TV를 선택하세요.";
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [_boxes count];
    }
    else if (section == 1)
    {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        static NSString *CellIdentifier = @"BoxCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.backgroundColor = RGB(245, 245, 245);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        // 박스 목록.
        CMBoxService *box = [_boxes objectAtIndex:indexPath.row];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        // 원래 코드.
        //cell.textLabel.text = box.name;
        // 수정 요청 사항.
        cell.textLabel.text = @"씨앤앰 스마트TV Ⅱ";
        
        // !!!: 공인IP가 잡히는 경우에 대한 예외 처리!
        // 사설IP(192로 시작...)  여부.
        if ([self isPrivateAddress:[box.addresses objectAtIndex:0]])
        {
            cell.detailTextLabel.text = [box.addresses objectAtIndex:0];
        }
        else
        {
            // 박스 이름에서 IP를 가져온다.
            cell.detailTextLabel.text = [self genAddress:box.name];
        }
        
        return cell;
    }
    else if (indexPath.section == 1)
    {
        static NSString *CellIdentifier = @"InputCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.backgroundColor = RGB(245, 245, 245);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.text = @"IP 주소 직접 입력.";
        
        return cell;
    }
    else return nil;
}

#pragma mark - Table view delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width - 20, 30)];
        headerView.backgroundColor = [UIColor clearColor];
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:headerView.frame];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textColor = UIColorFromRGB(0x7961aa);
        headerLabel.font = [UIFont boldSystemFontOfSize:17];
        headerLabel.text = @"셋탑박스를 선택하세요.";
        [headerView addSubview:headerLabel];
        return headerView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 선택 컬러.
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = UIColorFromRGB(0xd7cfe1);
    cell.textLabel.textColor = [UIColor whiteColor];
    self.currentCell = cell;
    
    if (indexPath.section == 0)
    {
        [_delegate didSelectBox:[_boxes objectAtIndex:[indexPath row]]];
        
        [self performSelector:@selector(resetCell) withObject:nil afterDelay:1];
    }
    else if (indexPath.section == 1)
    {
        CMSetIPViewController *viewControlelr = [[CMSetIPViewController alloc] initWithNibName:@"CMSetIPViewController" bundle:nil];
        viewControlelr.delegate = self;
        [CMAppDelegate.container pushViewController:viewControlelr animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
