
#import "DetailVC.h"
#import "HFStretchableTableHeaderView.h"
#import "DetailCell.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "UIImageView+WebCache.h"

@interface DetailVC ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate,CLLocationManagerDelegate>

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

//地圖
@property (weak, nonatomic) IBOutlet MKMapView *detailMap;


@property (weak, nonatomic) IBOutlet UISegmentedControl *selectBtn;


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
    
    if ([_detailObj[@"Picture1"] length] == 0) {
        _detailMap.hidden = NO;
        [_selectBtn setSelectedSegmentIndex:1];
    }else{
        NSString *urlStr = [_detailObj[@"Picture1"]
                            stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlStr];
        //判斷是有可圖片
        [_theImageView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error) {
                _detailMap.hidden = NO;
                [_selectBtn setSelectedSegmentIndex:1];
            }else{
                _detailMap.hidden = YES;
                _selectBtn.hidden = NO;
            }
        }];
    }
    
    
    
    
    
    
    
    
    
    
//    //計算區域
//    [_locationManager LocationZipCodeWithLatitude:_MyRestaurantLocation.coordinate.latitude
//                                    withLongitude:_MyRestaurantLocation.coordinate.longitude withCompletion:^(CLPlacemark *placemark) {
//                                        //創造大頭針物件
//                                        MKPointAnnotation *myPoint = [[MKPointAnnotation alloc] init];
//                                        //附加緯經度給-->大頭針座標
//                                        myPoint.coordinate = _MyRestaurantLocation.coordinate;
//                                        //地區取區域別
//                                        myPoint.title = placemark.locality;
//                                        //餐廳所在區域別
//                                        myPoint.subtitle = _tmpRestaurant.name;
//                                        //地圖附加大頭針
//                                        [_restaurantMapView addAnnotation:myPoint];
//                                    }];

    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

//customer cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentify = [NSString stringWithFormat:@"cell%ld", indexPath.row];
    DetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify forIndexPath:indexPath];
    //設定文字的粗體和大小
    cell.place.font = [UIFont boldSystemFontOfSize:17.0f];
    cell.address.font = [UIFont boldSystemFontOfSize:17.0f];
    cell.phone.font = [UIFont boldSystemFontOfSize:17.0f];
    cell.special.font = [UIFont boldSystemFontOfSize:17.0f];
    
    cell.place.text = _detailObj[@"Name"];
    cell.address.text = _detailObj[@"Add"];
    cell.phone.text = _detailObj[@"Tel"];
    cell.special.text = _detailObj[@"Toldescribe"];
    
    return cell;
}


- (IBAction)selectBtn:(UISegmentedControl *)sender {
    switch ([sender selectedSegmentIndex]) {
        case 0:
            _detailMap.hidden = YES;
            break;
        case 1:
            _detailMap.hidden = NO;
            break;
        default:
            break;
    }


}






- (IBAction)webSiteBtn:(id)sender {
}




@end
