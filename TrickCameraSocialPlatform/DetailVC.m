
#import "DetailVC.h"
#import "HFStretchableTableHeaderView.h"
#import "DetailCell.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "UIImageView+WebCache.h"
#import "LocationManager.h"
#import "WebViewController.h"

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
@property(nonatomic, strong) LocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UISegmentedControl *selectBtn;
@property(nonatomic) BOOL isFirstLocationReceived;

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
    //位置管理員
    _locationManager = [[LocationManager alloc] init];
    
    //計算區域
    [_locationManager LocationZipCodeWithLatitude:[_detailObj[@"location"] latitude]
                                    withLongitude:[_detailObj[@"location"] longitude]
                                   withCompletion:^(CLPlacemark *placemark) {
                                        //創造大頭針物件
                                        MKPointAnnotation *myPoint = [[MKPointAnnotation alloc] init];
                                        //附加緯經度給-->大頭針座標
                                       CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([_detailObj[@"location"] latitude], [_detailObj[@"location"] longitude]);
                                        myPoint.coordinate = coor;
                                        //地區取區域別
                                        myPoint.title = placemark.locality;
                                        //地圖附加大頭針
                                        [_detailMap addAnnotation:myPoint];
                                    }];
    
    if ([_detailObj[@"Website"] length] > 0) {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"inter.png"]
                                                       style:UIBarButtonItemStyleDone
                                                      target:self action:@selector(interButton:)];
        [rightButton setTintColor:[UIColor orangeColor]];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
}

-(void)interButton:(id)sender{
    WebViewController *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"webVC"];
    webVC.webURL = _detailObj[@"Website"];
    [self.navigationController pushViewController:webVC animated:NO];
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

//MapKit-->Pin客制化---->屬於MapKit
-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    //如果是系統的大頭針，則return nil
    if (annotation == _detailMap.userLocation) {
        return nil;
    }
    
    //先到資源回收桶找有沒有不要使用的大頭針-->如果沒有則create一個新的大頭針
    MKPinAnnotationView *customPin = (MKPinAnnotationView*)[_detailMap dequeueReusableAnnotationViewWithIdentifier:@"customPin"];
    if (customPin == nil) {
        customPin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"customPin"];
    }else{
        customPin.annotation = annotation;
    }
    customPin.canShowCallout = YES;
    customPin.animatesDrop = NO;
    
    
    //Pin附加Accessory
    UIImageView *theImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    //圖片栽剪成圓形
    theImageView.layer.cornerRadius = theImageView.frame.size.width/2;
    theImageView.clipsToBounds = YES;
    theImageView.contentMode = UIViewContentModeScaleToFill;
    NSString *urlStr = [_detailObj[@"Picture1"]
                        stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    [theImageView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!error) {
            customPin.leftCalloutAccessoryView = theImageView;
        }
    }];
    
    
    //導航功能加入
    //客制化大頭針-Add Right Callout Accessory View
    UIButton *rightBUtton = [[UIButton alloc] init];
    rightBUtton.frame = CGRectMake(0, 0, 40, 40);
    
    [rightBUtton setTitle:@"導航" forState:UIControlStateNormal];
    [rightBUtton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBUtton.backgroundColor = [UIColor orangeColor];

    //用程式碼去實現Button的監聽
    //forControlEvents-->參數是事件的種類
    [rightBUtton addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    customPin.rightCalloutAccessoryView = rightBUtton;

    
    
    //地圖移動到指定位置-->沒有開啟追蹤時用
    if (_isFirstLocationReceived ==false) {
        //不用加星號，因為本質是c語言的strct。只一個資料儲存的東西(不是物件)
        //把資料讀出來
        //coordinate-->座標
        MKCoordinateRegion region = _detailMap.region;
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([_detailObj[@"location"] latitude], [_detailObj[@"location"] longitude]);
        region.center = coor;
        //控制地圖的縮放-->無段式縮放 -->1度約1公里
        region.span.latitudeDelta = 0.03;
        //控制地圖的縮放-->無段式縮放
        region.span.longitudeDelta = 0.03;
        //跳過去的位置和動畫
        [_detailMap setRegion:region animated:NO];
        _isFirstLocationReceived = YES;
    }
    return customPin;
}

//自動顯示大頭針Annotation
-(void) mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    MKPinAnnotationView *pinView = (MKPinAnnotationView*)[views lastObject];
    [_detailMap selectAnnotation:pinView.annotation animated:YES];
}


//導航按鈕-->地址轉經緯度後，開始導航(結合—>轉經緯度+導航)
-(void)buttonPressed{
    //創造第2個MapItem—>導航用的專屬物件(屬於MapKit)-->目的地
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([_detailObj[@"location"] latitude], [_detailObj[@"location"] longitude]);
    MKPlacemark *targetPlace = [[MKPlacemark alloc] initWithCoordinate:coor addressDictionary:nil];
    
    //地圖導航用的物件-->目的地
    MKMapItem *targetMapItem = [[MKMapItem alloc] initWithPlacemark:targetPlace];
    targetMapItem.name = _detailObj[@"Name"];
    targetMapItem.phoneNumber = _detailObj[@"TEL"];
    
    //呼叫Apple Map後，可以帶參數過去
    NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving};
    //原地和指定地點的導航(單一指定位置)
    [targetMapItem openInMapsWithLaunchOptions:options];
}




@end
