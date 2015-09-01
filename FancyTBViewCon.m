
#import "FancyTBViewCon.h"
#import "FancyTBViewCell.h"
#import "MessageVCon.h"
#import "PeoplesVCon.h"

#import "UIImage+CustomUIImageEffect.h"
#import "UIImageView+ClipAndspecific.h"

#import <Social/Social.h>
//點擊照片
#import "JTSImageInfo.h"
#import "JTSImageViewController.h"

//parse and facebook 登入
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKGraphRequestConnection.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import "PFLogInViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "NSObject+SearchParse.m"
#import "NSObject+SaveParse.h"
#import "ParseDBSource.h"
//轉轉轉
#import <PQFCustomLoaders/PQFCustomLoaders.h>




@interface FancyTBViewCon ()<UIScrollViewDelegate, UIGestureRecognizerDelegate,
UITableViewDelegate, UITableViewDataSource, PFLogInViewControllerDelegate>

//custom cell
@property (nonatomic, strong) FancyTBViewCell *cell;
//Gesture
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *fancyPictureGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *likeGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *messageGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *shareGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *personalImageGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *theLongMessageGesture;

//parse and facebook 登入
@property(nonatomic, strong) PFLogInViewController *controller;

//Parse
@property(nonatomic, strong) PFImageView *pfImageview;
@property(nonatomic, strong) PFUser *user;
@property(nonatomic, strong) PFObject *likeObj;
@property(nonatomic, strong) ParseDBSource *pe;

//轉轉轉
@property (nonatomic, strong) PQFBouncingBalls *bouncingBalls;

@end

@implementation FancyTBViewCon

- (void)viewDidLoad {
    [super viewDidLoad];

    //轉轉轉
    _bouncingBalls = [PQFBouncingBalls createModalLoader];
    _bouncingBalls.loaderColor = [UIColor orangeColor];
    _bouncingBalls.jumpAmount = 60;
    _bouncingBalls.zoomAmount = 50;
    _bouncingBalls.separation = 30;
    _bouncingBalls.diameter = 20;
    _bouncingBalls.label.text = @"Download...";
    _bouncingBalls.label.textColor = [UIColor orangeColor];
    _bouncingBalls.fontSize = 20;
    
    
    //Facebook登入的部份還要再處理-->有Bug嚴重
    //下拉更新文字屬性
    //Check if user is cached
    if (![PFUser currentUser] ||
        ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        // Check if user is linked to Facebook
        _controller = [[PFLogInViewController alloc] init];
        _controller.delegate = self;
        //設定欄位
        _controller.fields = PFLogInFieldsFacebook;
        [self presentViewController:_controller animated:YES completion:nil];
        
    }else{
        //開始轉轉
        [_bouncingBalls showLoader];
        //Parse singleton 初始化
        _pe = [ParseDBSource shared];
        
        //background thread-1
        dispatch_queue_t bg1 = dispatch_queue_create("bg1", nil);
        dispatch_async(bg1, ^{
            //取得照片的all info
            [_pe getParseData:^(NSMutableArray *pfObject) {
                //取得主線程(main thread)
                dispatch_async(dispatch_get_main_queue(), ^{
                    //停止轉轉
                    [_bouncingBalls setHidden:YES];
                    [self.tableView reloadData];
                });
            }];
        });
        
        //background thread-2
        dispatch_queue_t bg2 = dispatch_queue_create("bg2", nil);
        dispatch_async(bg2, ^{
            //取得全部相片的各自全部留言-->回傳字典給DataSource
            [_pe getPhotoAllMessages:nil];
        });
    }
    
    
    //自適化TableViewCell高度
    self.tableView.estimatedRowHeight = 44.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    //下拉資料更新中
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(handleRefresh)
                  forControlEvents:UIControlEventValueChanged];
    
    //MESSAGE notification center
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageOK:)
                                                 name:MESSAGE_OK object:nil];
    //PEOPLE notification center
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peopleOK:)
                                                 name:PEOPLE_OK object:nil];
    
}
//MESSAGE notification center
-(void)messageOK:(NSNotification*)notification{
    NSLog(@"MESSAGE_OK完成同步");
    [self.tableView reloadData];
}
//PEOPLE notification center
-(void)peopleOK:(NSNotification*)notification{
    NSLog(@"peopleOK完成同步");
    [self.tableView reloadData];
}


//下拉更新method
-(void)handleRefresh{
    [self refreshTheBtn];
}
-(void)refreshTheBtn{
    //background thread-1
    dispatch_queue_t bg1 = dispatch_queue_create("bg1", nil);
    dispatch_async(bg1, ^{
        //取得照片的all info
        [_pe getParseData:^(NSMutableArray *pfObject) {
            //取得主線程(main thread)
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.refreshControl endRefreshing];
            });
        }];
    });
    
    //background thread-2
    dispatch_queue_t bg2 = dispatch_queue_create("bg2", nil);
    dispatch_async(bg2, ^{
        //取得相片的全部留言-->回傳字典給DataSource
        [_pe getPhotoAllMessages:nil];
    });
}



#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_pe.parseData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

//custom cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //取得各別的Cell的Identifier
    NSString *identifier = [NSString stringWithFormat:@"cell%ld", indexPath.row];
    //connetc custom TableViewCell
    _cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    //手勢初始化
    [self initGesture];
    
    //字型調整
    [_cell.userName  setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
    [_cell.postState  setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
//    [_cell.focusLblText  setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
    [_cell.postDate setFont:[UIFont fontWithName:@"Helvetica-Bold" size:10]];
    [_cell.postState  setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
    [_cell.likeLblText  setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
    [_cell.messageLblText  setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
    [_cell.shareLblText  setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
    
    //使uiimageview的陰影不影響Tableview的速度
    _cell.layer.shouldRasterize = YES;
    _cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    //Label對齊方式-最後一行自然對齊
    _cell.theNewMessage.textAlignment = NSTextAlignmentJustified;
    
    //這裡要重新設計過
    //最新的一筆留言-->要先做空數組判斷，不然一定會crasth
    if ([_pe.parseData[indexPath.section][@"messageAry"] count] == 0) {
        _cell.theNewMessage.text = @"留言";
    }else{
        _cell.theNewMessage.text = _pe.parseData[indexPath.section][@"messageAry"][0][@"message"];
    }
    
    
    //Post userName
    _cell.userName.text = _pe.parseData[indexPath.section][@"userPID"][@"displayName"];
    //NSDate轉字符串-->發佈日期
    NSDate *postDate = [_pe.parseData[indexPath.section] createdAt];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *currentDateString = [dateFormatter stringFromDate:postDate];
    _cell.postDate.text = currentDateString;
    

    //拍照地點
    _cell.postState.text = _pe.parseData[indexPath.section][@"postState"];
    //留言的數量-NSNumber轉NSString
    _cell.messageNumbers.text = [_pe.parseData[indexPath.section][@"messageNumbers"] stringValue];
    //喜歡數量
    _cell.likeNumbers.text = [_pe.parseData[indexPath.section][@"likeNumbers"] stringValue];
    
    
    PFUser *meUser = [PFUser currentUser];
    NSString *outcome = _pe.parseData[indexPath.section][[meUser objectId]];
    //判斷目前user是否喜歡該張照片，如果是則是實心的，如果不是則是空心的
    if ([outcome isEqualToString:@"yes"]) {
        _cell.likeImage.image = [UIImage imageNamed:@"love.png"];
    }else{
        _cell.likeImage.image = [UIImage imageNamed:@"love 2.png"];
    }
    

    //最新發佈圖-陰影效果
    _cell.fancyImageView = [UIImageView imageViewWithShadow:_cell.fancyImageView withColor:[UIColor blackColor]];
    //Parse download
    _pfImageview = [[PFImageView alloc] init];
    //原圖的縮略圖==>placeHolder
    PFFile *thumbnail = _pe.parseData[indexPath.section][@"photo"];
    NSData *imageData = [thumbnail getData];
    UIImage *thumbnailImage = [UIImage imageWithData:imageData];
    _pfImageview.image = thumbnailImage;
    [_pfImageview setFile:_pe.parseData[indexPath.section][@"photo"]];
    //縮圖
    _cell.fancyImageView.image = [UIImage imageCompressWithSimple:_pfImageview.image
                                                scaledToSizeWidth:320.0f
                                               scaledToSizeHeight:250.0f];
    
    //設定大頭照
    _cell.personalImageView = [UIImageView imageViewWithClipCircle: _cell.personalImageView];
    PFImageView *headPFimageView = [[PFImageView alloc] init];
    //原圖的縮略圖==>placeHolder
    PFFile *thumbnail_head = _pe.parseData[indexPath.section][@"usrPID"][@"headPhoto"];
    NSData *imageData_head = [thumbnail_head getData];
    UIImage *thumbnailImage_head = [UIImage imageWithData:imageData_head];
    headPFimageView.image = thumbnailImage_head;
    [headPFimageView setFile:_pe.parseData[indexPath.section][@"userPID"][@"headPhoto"]];
    
    
    //縮圖
    _cell.personalImageView.image = [UIImage imageCompressWithSimple:headPFimageView.image
                                                   scaledToSizeWidth:150.0f
                                               scaledToSizeHeight:150.0f];
    [headPFimageView loadInBackground];
    [_pfImageview loadInBackground];
    
    return _cell;
}


//往上滑動時隱藏NavigationBar-->delegate
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if (velocity.y >0) {
        self.navigationController.navigationBarHidden = YES;
    }else{
        self.navigationController.navigationBarHidden = NO;
    }
}

//手勢初始化
-(void) initGesture{
    //創造Tap手勢物件&加上單擊行為
    _fancyPictureGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fancyPictureGestureTapMotion:)];
    _personalImageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(personalImageGestureTapMotion:)];
    _likeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeGestureTapMotion:)];
    _messageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageGestureTapMotion:)];
    _shareGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareGestureTapMotion:)];
    _theLongMessageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(theLongMessageTapMotion:)];

    //附著手勢物件
    [_cell.fancyImageView addGestureRecognizer:_fancyPictureGesture];
    [_cell.personalImageView addGestureRecognizer:_personalImageGesture];
    [_cell.likeImage addGestureRecognizer:_likeGesture];
    [_cell.messageImageView addGestureRecognizer:_messageGesture];
    [_cell.shareImage addGestureRecognizer:_shareGesture];
    [_cell.theNewMessage addGestureRecognizer:_theLongMessageGesture];
}


//fancyPictureGestureTapMotion
-(void)fancyPictureGestureTapMotion:(UIGestureRecognizer*)sender{
    
    UIImageView *selectedImageView=(UIImageView*)[sender view];
    //取得NSIndexPath-->使用刺件的父物件的方法
    NSIndexPath *myIndexPath = [self.tableView indexPathForCell:(FancyTBViewCell *)[[selectedImageView superview] superview]];
    //因為返回的是UITableViewCell，所以要把她轉型為FancyTBviewCell
    FancyTBViewCell *customCell =(FancyTBViewCell*)[self.tableView cellForRowAtIndexPath:myIndexPath];
    //點擊照片跳出
    [UIImage createTapPictureJTSImageViewController:customCell.fancyImageView.image
                                 withInputImageView:customCell.fancyImageView withInputViewController:self];
}

//personalImageGestureTapMotion
-(void)personalImageGestureTapMotion:(UIGestureRecognizer*)sender{
    PeoplesVCon *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PeoplePage"];
    [self.navigationController pushViewController:vc animated:YES];
}


//likeGestureTapMotion
-(void)likeGestureTapMotion:(UIGestureRecognizer*)sender{
    
    UIImageView *selectedImageView=(UIImageView*)[sender view];
    //取得NSIndexPath-->使用刺件的父物件的方法-->這裡是Contentview
    NSIndexPath *myIndexPath = [self.tableView indexPathForCell:(FancyTBViewCell *)[[selectedImageView superview] superview]];
    //因為返回的是UITableViewCell，所以要把她轉型為FancyTBviewCell-->用不到
    //FancyTBViewCell *customCell =(FancyTBViewCell*)[self.tableView cellForRowAtIndexPath:myIndexPath];
    
    //更換喜歡圖片
    PFUser *meUser = [PFUser currentUser];
    NSString *outcome = _pe.parseData[myIndexPath.section][[meUser objectId]];
    
    //判斷目前user是否喜歡該張照片
    if ([outcome isEqualToString:@"yes"]) {
        selectedImageView.image = [UIImage imageNamed:@"love 2.png"];
        [_pe.parseData[myIndexPath.section] incrementKey:@"likeNumbers" byAmount:@-1];
        [_pe.parseData[myIndexPath.section] setObject:@"no" forKey:[meUser objectId]];
        //刪除Like集合裡喜歡的照片
        [NSObject removeFocusUserLikeWithPhotoID:[_pe.parseData[myIndexPath.section] objectId]
                                      withUserID:meUser.objectId completions:nil];
    }else{
        [_pe.parseData[myIndexPath.section] incrementKey:@"likeNumbers"];
        [_pe.parseData[myIndexPath.section] setObject:@"yes" forKey:[meUser objectId]];
        selectedImageView.image = [UIImage imageNamed:@"love.png"];
        [NSObject saveOneObjectWithClassName:@"Likes" complection:^(PFObject *pfObject) {
            //likes-userID欄位
            [pfObject setObject:meUser.objectId forKey:@"userID"];
            //likes-photoID欄位
            [pfObject setObject:[_pe.parseData[myIndexPath.section] objectId] forKey:@"photoID"];
            [pfObject saveInBackground];
        }];
    }
    
    [_pe.parseData[myIndexPath.section] saveInBackground];
    //局部section刷新
    //刷新的部位-->section
    NSIndexPath *te=[NSIndexPath indexPathForRow:3 inSection:myIndexPath.section];
    //開始刷新
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:te,nil]
                          withRowAnimation:UITableViewRowAnimationNone];
}




//messageGestureTapMotion
-(void)messageGestureTapMotion:(UIGestureRecognizer*)sender{
    MessageVCon *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"messageStoryBoard"];
    //取得NSIndexPath-->使用刺件的父物件的方法
    UIImageView *selectedImageView=(UIImageView*)[sender view];
    NSIndexPath *myIndexPath = [self.tableView indexPathForCell:(FancyTBViewCell *)[[selectedImageView superview] superview]];
    //傳選擇的photo物件-->選擇的照片物件
    vc.selectPhotoObj = _pe.parseData[myIndexPath.section];
    [self.navigationController pushViewController:vc animated:YES];
}


//shareGestureTapMotion
-(void)shareGestureTapMotion:(UIGestureRecognizer*)sender{
    //好像一次只能跳出一個分享-->這裡是Facebook
    SLComposeViewController *socialController = [SLComposeViewController
                                                 composeViewControllerForServiceType:SLServiceTypeFacebook];
    // add initial text
    [socialController setInitialText:@"Hello Facebook!"];
    // add an image
    [socialController addImage:[UIImage imageNamed:@"98.jpg"]];
    // add a URL
    [socialController addURL:[NSURL URLWithString:@"http://wpguru.co.uk"]];
    // present controller
    [self presentViewController:socialController animated:YES completion:nil];
}


//theLongMessageTapMotion
-(void)theLongMessageTapMotion:(UIGestureRecognizer*)sender{
    MessageVCon *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"messageStoryBoard"];
    //取得NSIndexPath-->使用刺件的父物件的方法
    UIImageView *selectedImageView=(UIImageView*)[sender view];
    NSIndexPath *myIndexPath = [self.tableView indexPathForCell:(FancyTBViewCell *)[[selectedImageView superview] superview]];
    //傳選擇的photo物件-->選擇的照片物件
    vc.selectPhotoObj = _pe.parseData[myIndexPath.section];
    [self.navigationController pushViewController:vc animated:YES];
}



////parse and facebook 登入
//-(void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    //下拉更新文字屬性
//    //Check if user is cached
//    if (![PFUser currentUser] ||
//        ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
//        // Check if user is linked to Facebook
//        _controller = [[PFLogInViewController alloc] init];
//        _controller.delegate = self;
//        //設定欄位
//        _controller.fields = PFLogInFieldsFacebook;
//        [self presentViewController:_controller animated:YES completion:nil];
//        
//    }
//}


//Protocol-->登入完成時用
//已經登錄的@protocol
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user{
    //取消登入畫面
    [self dismissViewControllerAnimated:YES completion:nil];
}





@end
