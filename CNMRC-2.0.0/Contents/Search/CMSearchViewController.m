//
//  CMSearchViewController.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 17..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMSearchViewController.h"
#import "CMTableViewCell.h"
#import "SearchHistory.h"
#import "CMWebViewController.h"
#import "CMVODListTableViewCell.h"
#import "CMVODDetailViewController.h"
#import "CMChannelTableViewCell.h"
#import "DQAlertView.h"
#import "CMAuthAdultViewController.h"

@interface CMSearchViewController ()
{
    BOOL _isSearching;
    CMSearchType _searchType;
}

- (void)resetUI:(BOOL)status;
- (void)setupSearchHistory;
- (void)saveSearchKeyword:(NSString *)keyword;
- (void)deleteSearchHistory;
- (void)search:(CMSearchType)searchType withKeyword:(NSString *)keyword;
- (void)searchVOD:(NSString *)keyword;
- (void)searchProgram:(NSString *)keyword;
- (void)searchNaver:(NSString *)keyword;
- (NSString *)deletHTML:(NSString *)html;
- (void)checkAdult;
@end

@implementation CMSearchViewController

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
    
    CGFloat paddingY = 0.0;
    if (isiOS7)
    {
//        self.searchBar.backgroundColor = [UIColor whiteColor];
//        self.searchBar.tintColor = [UIColor whiteColor];
        self.searchBar.barTintColor = UIColorFromRGB(0x252525);
        
        paddingY = 20.0;
        self.backgroundImageView.center = CGPointMake(self.backgroundImageView.center.x, self.backgroundImageView.center.y + paddingY);
        self.deleteSearchHistoryButton.center = CGPointMake(self.deleteSearchHistoryButton.center.x, self.deleteSearchHistoryButton.center.y + paddingY);
        self.vodButton.center = CGPointMake(self.vodButton.center.x, self.vodButton.center.y + paddingY);
        self.programButton.center = CGPointMake(self.programButton.center.x, self.programButton.center.y + paddingY);
        self.naverButton.center = CGPointMake(self.naverButton.center.x, self.naverButton.center.y + paddingY);
        self.resultTable.center = CGPointMake(self.resultTable.center.x, self.resultTable.center.y + paddingY);
    }
    
    self.searchBar.frame = CGRectMake(0.0, 0.0 + paddingY, 320.0, 55.0);
    for (UIView *subview in self.searchBar.subviews)
    {
        if([subview isKindOfClass:[UIButton class]])
        {
            [(UIButton *)subview setEnabled:YES];
            [(UIButton *)subview setTitle:@"닫기" forState:UIControlStateNormal];
        }
        
        if (isiOS7)
        {
            for (UIView *sb in subview.subviews)
            {
                if([sb isKindOfClass:[UIButton class]])
                {
                    [(UIButton *)sb setEnabled:YES];
                    [(UIButton *)sb setTitle:@"닫기" forState:UIControlStateNormal];
                    [(UIButton *)sb setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
            }
        }
    }
    
    [self.view bringSubviewToFront:self.searchBar];
    
    self.view.backgroundColor = UIColorFromRGB(0xe5e5e5);
    self.vodButton.selected = YES;
    
    // 최근 검색어 설정.
    //[self setupSearchHistory];
    
    NSArray *histories = [SearchHistory all];
    if (histories.count == 0)
    {
        [self resetUI:YES];
    }
    else
    {
        [self resetUI:NO];
        [self setupSearchHistory];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setEmptyLabel:nil];
    [self setSearchBar:nil];
    [self setResultTable:nil];
    [self setVodButton:nil];
    [self setProgramButton:nil];
    [self setNaverButton:nil];
    [super viewDidUnload];
}

#pragma mark - 프라이빗 메서드

// UI 설정.
- (void)resetUI:(BOOL)status
{
    self.emptyLabel.hidden = !status;
    self.backgroundImageView.hidden = status;
    self.deleteSearchHistoryButton.hidden = status;
    self.vodButton.hidden = status;
    self.programButton.hidden = status;
    self.naverButton.hidden = status;
    self.resultTable.hidden = status;
}

// 최근 검색어 설정.
- (void)setupSearchHistory
{
    NSArray *histories = [SearchHistory all];
    
    if ([histories count] > 0)
    {
        // !!!: 날짜 역순.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"searchDate" ascending:NO];
        
        self.results = [NSMutableArray arrayWithArray:[histories sortedArrayUsingDescriptors:@[sortDescriptor]]];
        [self.resultTable reloadData];
    }
    else
    {
        self.deleteSearchHistoryButton.hidden = YES;
    }
}

// 검색어 저장.
- (void)saveSearchKeyword:(NSString *)keyword
{
    // 중복 제거.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"keyword = %@", keyword];
    if ([[SearchHistory where:predicate] count] > 0)
        return;
    
    SearchHistory *history = [SearchHistory create];
    history.keyword = self.searchBar.text;
    history.searchDate = [NSDate date];
    [history save];
}

// 최근 검색어 삭제.
- (void)deleteSearchHistory
{
    [SearchHistory deleteAll];
    [self.resultTable reloadData];
}

// 검색.
- (void)search:(CMSearchType)searchType withKeyword:(NSString *)keyword
{
    switch (searchType)
    {
        case CMSearchTypeVOD:
        {
            [self searchVOD:keyword];
        }
            break;
            
        case CMSearchTypeProgram:
        {
            [self searchProgram:keyword];
        }
            break;
            
        case CMSearchTypeNaver:
        {
            [self searchNaver:keyword];
        }
            break;
            
        default:
            break;
    }
}

// VOD 검색.
- (void)searchVOD:(NSString *)keyword
{
    NSURL *url = [CMGenerator genURLWithInterface:CNM_OPEN_API_INTERFACE_SearchVod];
    NSDictionary *dict = @{
                           CNM_OPEN_API_VERSION_KEY : CNM_OPEN_API_VERSION,
                           CNM_OPEN_API_TERMINAL_KEY_KEY : [CMHTTPClient sharedCMHTTPClient].terminalKey,
                           CNM_OPEN_API_TRANSACTION_ID_KEY : @"0",
                           @"sortType" : @"TitleAsc",
                           @"pageSize" : @"0",
                           @"pageIndex" : @"0",
                           @"Search_String" : [keyword stringByUrlEncoding]
                           };
    
    request(url, self, dict, YES);
}

// !!!: 지역코드(areaCode)와 상품코드(productCode)의 기본값을 확인해야 한다.
// 프로그램 검색.
- (void)searchProgram:(NSString *)keyword
{
    NSURL *url = [CMGenerator genURLWithInterface:CNM_OPEN_API_INTERFACE_SearchProgram];
    NSDictionary *dict = @{
                           CNM_OPEN_API_VERSION_KEY : CNM_OPEN_API_VERSION,
                           CNM_OPEN_API_TERMINAL_KEY_KEY : [CMHTTPClient sharedCMHTTPClient].terminalKey,
                           CNM_OPEN_API_TRANSACTION_ID_KEY : @"0",
                           @"areaCode" : CNM_DEFAULT_AREA_CODE,
                           @"productCode" : CNM_DEFAULT_PRODUCT_CODE,
                           @"pageSize" : @"0",
                           @"pageIndex" : @"0",
                           @"Search_String" : [keyword stringByUrlEncoding]
                           };
    
    request(url, self, dict, YES);
}

// 네이버 검색.
- (void)searchNaver:(NSString *)keyword
{
    NSURL *url = [CMGenerator genURLWithQuery:keyword];
    request(url, self, nil, YES);
}

// HTML 태그 삭제.
- (NSString *)deletHTML:(NSString *)html
{
    NSString *str = html;
    
    str = [str stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
    
    return str;
}

// 성인인증 확인.
- (void)checkAdult
{
    DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"알림"
                                                        message:@"성인인증이 필요한 컨텐츠 입니다.\n 성인인증을 하시겠습니까?"
                                              cancelButtonTitle:@"취소"
                                               otherButtonTitle:@"확인"];
    alertView.otherButtonAction = ^{
        Debug(@"OK Clicked");
        // 성인인증.
        CMAuthAdultViewController *viewControlelr = [[CMAuthAdultViewController alloc] initWithNibName:@"CMAuthAdultViewController" bundle:nil];
        viewControlelr.menuType = CMMenuTypeAuthAdult;
        viewControlelr.authAdultViewType = CMAuthAdultViewTypeVOD;
        [self.navigationController pushViewController:viewControlelr animated:YES];
    };
    
    [alertView show];
}

#pragma mark - 퍼블릭 메서드

// 검색 타입 변경.
- (IBAction)searchTypeAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    switch (button.tag)
    {
        case 0:
        {
            self.vodButton.selected = YES;
            self.programButton.selected = NO;
            self.naverButton.selected = NO;
        }
            break;
            
        case 1:
        {
            self.vodButton.selected = NO;
            self.programButton.selected = YES;
            self.naverButton.selected = NO;
        }
            break;
            
        case 2:
        {
            self.vodButton.selected = NO;
            self.programButton.selected = NO;
            self.naverButton.selected = YES;
        }
            break;
            
        default:
            break;
    }
    
    _searchType = button.tag;
    _isSearching = NO;
    self.deleteSearchHistoryButton.hidden = NO;
    [self setupSearchHistory];
}

// 최근 검색어 삭제.
- (IBAction)deleteSearchHistoryAction:(id)sender
{
    DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"최근 검색어 삭제"
                                                       message:@"최근 검색어를 모두 삭제하시겠습니까?"
                                             cancelButtonTitle:@"취소"
                                              otherButtonTitle:@"확인"];
    alertView.otherButtonAction = ^{
        Debug(@"OK Clicked");
        // 최근 검색어 삭제.
        [self deleteSearchHistory];
    };
    
    [alertView show];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self resetUI:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    // 검색.
    [self search:_searchType withKeyword:aSearchBar.text];
    
    // 검색어 저장.
    [self saveSearchKeyword:aSearchBar.text];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isSearching)
    {
        switch (_searchType)
        {
        case CMSearchTypeVOD:
            {
                static NSString *CellIdentifier = @"VODCell";
                CMVODListTableViewCell *cell = (CMVODListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil)
                {
                    cell = [[CMVODListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                    [cell setDashWidth:1 dashGap:0 dashStroke:1];
                    [cell setBackgroundViewColor:UIColorFromRGB(0xe5e5e5)];
                    [cell setSelectedBackgroundViewColor:UIColorFromRGB(0xd7cfe1)];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                
                // HD 여부.
                cell.isHD = [[[self.results objectAtIndex:indexPath.row] valueForKey:@"VOD_HD"] boolValue];
                
                // 시청등급.
                cell.vodGrade = [[[self.results objectAtIndex:indexPath.row] valueForKey:@"VOD_Grade"] integerValue];
                
                // VOD 이미지.
                if (cell.vodGrade == 19 && !AppInfo.isAdult)
                {
                    cell.screenshotImageView.image = [UIImage imageNamed:@"vodlist19.jpg"];
                }
                else
                {
                    NSURL *url = [NSURL URLWithString:[[self.results objectAtIndex:indexPath.row] valueForKey:@"VOD_IMG"]];
                    cell.screenshotImageView.imageURL = url;
                }
                
                cell.titleLabel.text = [[self.results objectAtIndex:indexPath.row] valueForKey:@"VOD_Title"];
                cell.directorLabel.text = [NSString stringWithFormat:@"감독: %@",  [[self.results objectAtIndex:indexPath.row] valueForKey:@"VOD_Director"]];
                cell.castingLabel.text = [NSString stringWithFormat:@"배우: %@", [[self.results objectAtIndex:indexPath.row] valueForKey:@"VOD_Actor"]];
                
                return cell;
            }
            break;
            
        case CMSearchTypeProgram:
            {
                static NSString *CellIdentifier = @"ProgramCell";
                CMChannelTableViewCell *cell = (CMChannelTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil)
                {
                    cell = [[CMChannelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                    [cell setSeparatorColor:[UIColor redColor]];
                    [cell setDashWidth:1 dashGap:0 dashStroke:1];
                    [cell setBackgroundViewColor:UIColorFromRGB(0xe5e5e5)];
                    [cell setSelectedBackgroundViewColor:UIColorFromRGB(0xd7cfe1)];
                }
                
                // 채널 번호.
                cell.channelNoLabel.text = [[self.results objectAtIndex:indexPath.row] valueForKey:@"Channel_number"];
                
                // 채널 로고.
                NSURL *url = [NSURL URLWithString:[[self.results objectAtIndex:indexPath.row] valueForKey:@"Channel_logo_img"]];
                cell.channelIcon.imageURL = url;
                
                // 프로그램명.
                cell.programLabel.text = [[self.results objectAtIndex:indexPath.row] valueForKey:@"Channel_Program_Title"];
                
                // 시간.
                cell.nextProgramLabel.text = [[self.results objectAtIndex:indexPath.row] valueForKey:@"Channel_Program_Time"];
                
                return cell;
            }
            break;
            
        case CMSearchTypeNaver:
            {
                static NSString *CellIdentifier = @"NaverCell";
                CMTableViewCell *cell = (CMTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil)
                {
                    cell = [[CMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                    [cell.textLabel setTextColor:[UIColor lightGrayColor]];
                    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:18]];
                    [cell.textLabel setHighlightedTextColor:[UIColor whiteColor]];
                    [cell setDashWidth:1 dashGap:0 dashStroke:1];
                    [cell setBackgroundViewColor:UIColorFromRGB(0xe5e5e5)];
                    [cell setSelectedBackgroundViewColor:UIColorFromRGB(0xd7cfe1)];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                
                // Configure the cell...
                NSString *html = [[[self.results objectAtIndex:indexPath.row] valueForKey:@"title"] stringByConvertingHTMLToPlainText];
                cell.textLabel.text = [self deletHTML:html];
                
                return cell;
            }
            break;
            
        default:
            break;
        }
    }
    else
    {
        static NSString *CellIdentifier = @"KeywordCell";
        CMTableViewCell *cell = (CMTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[CMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell.textLabel setTextColor:[UIColor lightGrayColor]];
            [cell.textLabel setFont:[UIFont boldSystemFontOfSize:18]];
            [cell.textLabel setHighlightedTextColor:[UIColor whiteColor]];
            [cell setDashWidth:1 dashGap:0 dashStroke:1];
            [cell setBackgroundViewColor:UIColorFromRGB(0xe5e5e5)];
            [cell setSelectedBackgroundViewColor:UIColorFromRGB(0xd7cfe1)];
        }
        
        // Configure the cell...
        SearchHistory *sh = (SearchHistory *)[self.results objectAtIndex:indexPath.row];
        cell.textLabel.text = sh.keyword;
        
        return cell;
    }
    
    return nil;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!_isSearching && [[SearchHistory all] count] > 0)
    {
        return 30;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 44.0;
    if (_isSearching && _searchType == CMSearchTypeVOD)
    {
        cellHeight = 73.0;
    }
    
    return cellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!_isSearching && [[SearchHistory all] count] > 0)
    {
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 30.0)];
        header.backgroundColor = UIColorFromRGB(0xbababa);
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:header.frame];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:12];
        headerLabel.text = @" 최근 검색어";
        [header addSubview:headerLabel];
        
        return header;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isSearching)
    {
        switch (_searchType)
        {
            case CMSearchTypeVOD:
            {
                // VOD 등급과 성인인증 여부를 확인한다.
                NSInteger grade = [[[self.results objectAtIndex:indexPath.row] valueForKey:@"VOD_Grade"] integerValue];
                if (grade == 19 && !AppInfo.isAdult)
                {
                    [self checkAdult];
                }
                else
                {
                    CMVODDetailViewController *viewController = [[CMVODDetailViewController alloc] initWithNibName:@"CMVODDetailViewController" bundle:nil];
                    viewController.menuType = CMMenuTypeSearch;
                    viewController.viewControllerType = CMViewControllerTypeView;
                    viewController.data = [self.results objectAtIndex:indexPath.row];
                    [self.navigationController pushViewController:viewController animated:YES];
                }
            }
                break;
                
            case CMSearchTypeProgram:
            {
                // 채널의 프로그램은 상세 정보가 없다.
            }
                break;
                
            case CMSearchTypeNaver:
            {
                CMWebViewController *viewController = [[CMWebViewController alloc] initWithNibName:@"CMWebViewController" bundle:nil];
                viewController.url = [[self.results objectAtIndex:indexPath.row] valueForKey:@"link"];
                [self.navigationController pushViewController:viewController animated:YES];
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        // 최근 검색어 선택 설정.
        CMTableViewCell *cell = (CMTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        self.searchBar.text = cell.textLabel.text;
        [self.searchBar becomeFirstResponder];
    }
}

#pragma mark - CMHTTPClientDelegate

- (void)receiveData:(NSDictionary *)dict
{
    Debug(@"Receive data: %@", dict);
    
    switch (_searchType)
    {
        case CMSearchTypeVOD:
        {
            NSInteger errorCode = [[dict valueForKey:@"resultCode"] integerValue];
            if (errorCode == 100)
            {
                self.results = [NSMutableArray arrayWithArray:[dict valueForKey:@"VodSearch_Item"]];
            }
            else
            {
                // 에러 메시지.
                [self showError:errorCode];
                return;
            }
        }
            break;
            
        case CMSearchTypeProgram:
        {
            NSInteger errorCode = [[dict valueForKey:@"resultCode"] integerValue];
            if (errorCode == 100)
            {
                self.results = [NSMutableArray arrayWithArray:[dict valueForKey:@"ProgramSearch_Item"]];
            }
            else
            {
                // 에러 메시지.
                [self showError:errorCode];
                return;
            }
        }
            break;
            
        case CMSearchTypeNaver:
        {
            self.results = [NSMutableArray arrayWithArray:[[dict valueForKey:@"channel"] valueForKey:@"item"]];
        }
            break;
            
        default:
            break;
    }
    
    [self resetUI:NO];
    _isSearching = YES;
    self.deleteSearchHistoryButton.hidden = YES;
    [self.resultTable reloadData];
    [self.searchBar resignFirstResponder];
}

@end
