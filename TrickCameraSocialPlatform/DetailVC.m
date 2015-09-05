
#import "DetailVC.h"
#import "HFStretchableTableHeaderView.h"
#import "DetailCell.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface DetailVC ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *theUIView;
@property (weak, nonatomic) IBOutlet UIImageView *theImageView;
//HFStretchableTableHeaderView-->放大縮小效果
@property (nonatomic, strong) HFStretchableTableHeaderView* stretchableTableHeaderView;

//customer Tableview
//自設定TableView in  IBOutlet-->在ViewController內自建TableView一定要用程式碼先建立這一段IBOutlet
//然後再從storyboard上面的TableView拉過來聯結，才會生效
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//去官網的Button
@property (weak, nonatomic) IBOutlet UIBarButtonItem *webSiteBtn;




@end

@implementation DetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //消去TableView最後沒用到的欄位的分隔線
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    //prepare backgroundImageView放大縮小效果
    _stretchableTableHeaderView = [HFStretchableTableHeaderView new];
    [_stretchableTableHeaderView stretchHeaderForTableView:_tableView withView:_theUIView];
    
    //自適化TableViewCell高度
    self.tableView.estimatedRowHeight = 44.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

//customer cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentify = [NSString stringWithFormat:@"cell%ld", indexPath.row];
    DetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify forIndexPath:indexPath];
    
    cell.place.text = _detailObj[@"Name"];
    cell.address.text = _detailObj[@"Add"];
    cell.phone.text = _detailObj[@"Tel"];
    cell.special.text = _detailObj[@"Toldescribe"];
    cell.testdd.text = _detailObj[@"Toldescribe"];
    
    return cell;
}




- (IBAction)selectMap:(id)sender {
}


- (IBAction)webSiteBtn:(id)sender {
}




@end
