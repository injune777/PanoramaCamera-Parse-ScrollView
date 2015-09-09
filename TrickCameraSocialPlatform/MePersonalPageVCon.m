
#import "MePersonalPageVCon.h"
#import "MePersonalPageTBCell.h"

#import "SWRevealViewController.h"

#import "HFStretchableTableHeaderView.h"
#import "MessageVCon.h"

#import "UIImage+CustomUIImageEffect.h"
#import "UIImageView+ClipAndspecific.h"

//parse and facebook 登入
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKGraphRequestConnection.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseUI/ParseUI.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

#import "ParseDBSource.h"
#import "NSObject+SaveParse.h"
#import "NSObject+SearchParse.h"

#import "FollowTB.h"



@interface MePersonalPageVCon ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate,
UIGestureRecognizerDelegate>

//背景照
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
//頭照
@property (weak, nonatomic) IBOutlet UIImageView *headPictureImageView;
//customer cell
@property(nonatomic, strong) MePersonalPageTBCell *cell;

//customer Tableview
//自設定TableView in  IBOutlet-->在ViewController內自建TableView一定要用程式碼先建立這一段IBOutlet
//然後再從storyboard上面的TableView拉過來聯結，才會生效
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//HFStretchableTableHeaderView-->放大縮小效果
@property (nonatomic, strong) IBOutlet UIView* stretchView;
@property (nonatomic, strong) HFStretchableTableHeaderView* stretchableTableHeaderView;

//正被關注數量(跟隨者)
@property (weak, nonatomic) IBOutlet UILabel *followersNum;
//我的關注數量(追隨)
@property (weak, nonatomic) IBOutlet UILabel *followeringNum;

//個人介紹
@property (weak, nonatomic) IBOutlet UILabel *personalDes;
//PictureWall->Tap手勢物件
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *leftImageViewTapGesture;

//Parse
@property(nonatomic, strong) PFImageView *pfImageview;
@property(nonatomic, strong) PFObject *photoObject;

@property(nonatomic, strong) ParseDBSource *pe;
@property(nonatomic, strong) NSIndexPath *myIndexPath;


//Slide Bar
@property(nonatomic, strong) UIBarButtonItem *slideBarBtn;

//左邊-->跟隨者
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *followerGesture;
//正在跟隨的人
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *followeringGesture;

//追蹤我的人的array
@property(strong, nonatomic) NSMutableArray *followerArray;
//我追蹤的人的array
@property(strong, nonatomic) NSMutableArray *followeringArray;

@end


@implementation MePersonalPageVCon

- (void)viewDidLoad {
    [super viewDidLoad];
    //app使用者
    _selectPhotoObj = [PFUser currentUser];
    _slideBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"slideBar.png"]
                                                    style:UIBarButtonItemStyleDone
                                                   target:self
                                                   action:nil];
    [_slideBarBtn setTintColor:[UIColor orangeColor]];
    self.navigationItem.leftBarButtonItem = _slideBarBtn;
    //Slide Bar Menu
    SWRevealViewController *revealViewController = [self revealViewController];
    if (revealViewController) {
        //調整寬度
        revealViewController.rearViewRevealWidth = 220;
        [_slideBarBtn setTarget:self.revealViewController];
        [_slideBarBtn setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
    
    //手勢初始化
    _followerGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followerTapGesture:)];
    _followeringGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followeringTapGesture:)];
    [_followersNum addGestureRecognizer:_followerGesture];
    [_followeringNum addGestureRecognizer:_followeringGesture];
    
    
    //移除tableView分隔線
    self.tableView.separatorStyle = NO;
    //消去TableView最後沒用到的欄位的分隔線
    self.tableView.tableFooterView = [[UIView alloc] init];
    //Navigation title標題
    [self.navigationItem setTitle:_selectPhotoObj[@"displayName"]];
    
    
    //prepare backgroundImageView放大縮小效果
    _stretchableTableHeaderView = [HFStretchableTableHeaderView new];
    [_stretchableTableHeaderView stretchHeaderForTableView:self.tableView withView:_stretchView];
    //頭像改成圓形
    _headPictureImageView = [UIImageView imageViewWithClipCircle:_headPictureImageView];
    //縮圖
    _headPictureImageView.image = [UIImage imageCompressWithSimple:nil
                                                 scaledToSizeWidth:150.0f scaledToSizeHeight:150.0f];
    //設定大頭照
    _headPictureImageView = [UIImageView imageViewWithClipCircle: _headPictureImageView];
    PFImageView *headPFimageView = [[PFImageView alloc] init];
    headPFimageView.image = [UIImage imageNamed:@"photo-placeholder.png"];
    //parse資料
    [headPFimageView setFile:_selectPhotoObj[@"headPhoto"]];
    //縮圖
    _headPictureImageView.image = [UIImage imageCompressWithSimple:headPFimageView.image scaledToSizeWidth:150.0f
                                                scaledToSizeHeight:150.0f];
    
    [headPFimageView loadInBackground];
    //頭像添加邊框
    CALayer * layer = [_headPictureImageView layer];
    layer.borderColor = [[UIColor whiteColor] CGColor];
    layer.borderWidth = 4.0f;
    //頭像添加四个邊陰影
    _headPictureImageView = [UIImageView imageViewWithShadow:_headPictureImageView withColor:[UIColor whiteColor]];
    
    //自適化TableViewCell高度
    self.tableView.estimatedRowHeight = 44.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    //單例模式
    _pe = [ParseDBSource shared];

}


//取得追蹤我的人
-(void)followerTapGesture:(UIGestureRecognizer*)sender{
    NSLog(@"左邊");
    
    FollowTB *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"follower"];
    vc.followArray = _followerArray;
    [self.navigationController pushViewController:vc animated:YES];
    
}

//取得我追蹤的人
-(void)followeringTapGesture:(UIGestureRecognizer*)sender{
    NSLog(@"右邊");
    
    FollowTB *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"follower"];
    vc.followArray = _followeringArray;
    [self.navigationController pushViewController:vc animated:YES];
    
   
}



//更新而存在
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //create sub thread
    dispatch_queue_t bg1 = dispatch_queue_create("bg1", nil);
    dispatch_async(bg1, ^{
        [NSObject getFocusUserAllPostPhotoWithUserID:_selectPhotoObj.objectId
                                          completion:^(NSMutableArray *completion) {
                                              _pe.focusUserALlPicts = completion;
                                              //get main thread
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [self.tableView reloadData];
                                              });
                                          }];
    });
    
    //取得追隨數量
    [self getFollowNumbers];
    

    PFUser *currentUser = [PFUser currentUser];
    //取得追蹤我的人
    dispatch_queue_t bg2 = dispatch_queue_create("bg2", nil);
    dispatch_async(bg2, ^{
        
        [NSObject getFollowerNumbersWithCurrentUser:currentUser completion:^(NSMutableArray *completion){
            _followerArray = completion;
            NSLog(@"取得追蹤我的人OK");
        }];
        
    });
    
    //取得我追蹤的人
    dispatch_queue_t bg3 = dispatch_queue_create("bg3", nil);
    dispatch_async(bg3, ^{
        [NSObject getFolloweringNumbersWithCurrentUser:currentUser completion:^(NSMutableArray *completion) {
            _followeringArray = completion;
             NSLog(@"取得我追蹤的人OK");
        }];
    });
}


//取得追隨數量
-(void)getFollowNumbers{
    //follower numbers
    [NSObject getFollowerNumbersWithCurrentUser:(PFUser*)_selectPhotoObj
                                     completion:^(NSMutableArray *completion) {
                                         NSUInteger number = [completion count];
                                         _followersNum.text = [NSString stringWithFormat:@"%lu", number];
                                     }];
    //followering numbers
    [NSObject getFolloweringNumbersWithCurrentUser:(PFUser*)_selectPhotoObj
                                        completion:^(NSMutableArray *completion) {
                                            NSUInteger number = [completion count];
                                            _followeringNum.text = [NSString stringWithFormat:@"%lu", number];
                                        }];
}





- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_pe.focusUserALlPicts count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }else{
        return 2;
    }
}

//customer cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    _myIndexPath = indexPath;
    //取得各別的Cell的Identifier
    if (_myIndexPath.section == 0) {
        //取得各別的Cell的Identifier
        NSString *cellIdentify = [NSString stringWithFormat:@"cell%ld", _myIndexPath.row];
        _cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify forIndexPath:_myIndexPath];
        [self getInfoInCell];
        return _cell;
    }else{
        //取得各別的Cell的Identifier
        NSInteger customRow = _myIndexPath.row + 1;
        NSString *cellIdentify = [NSString stringWithFormat:@"cell%ld", customRow];
        _cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify forIndexPath:_myIndexPath];
        [self getInfoInCell];
        return _cell;
    }
    
    //    //左邊手勢
    //    _leftImageViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftTapMotion:)];
    //    //imageView附著手勢物件-->左邊圖片
    //    [_cell.peopleImageViewLeft addGestureRecognizer:_leftImageViewTapGesture];
    //
}

//使靜態Cell背景透明
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.backgroundColor = [UIColor clearColor];
}


-(void)getInfoInCell{
    
    

    
    //原圖的縮略圖
    PFImageView *pfLeftImageview = [[PFImageView alloc] init];
    PFFile *thumbnail = _pe.focusUserALlPicts[_myIndexPath.section][@"photo"];
    NSData *imageData = [thumbnail getData];
    UIImage *thumbnailImage = [UIImage imageWithData:imageData];
    pfLeftImageview.image = thumbnailImage;
    [pfLeftImageview setFile:_pe.focusUserALlPicts[_myIndexPath.section][@"photo"]];
    //縮圖
    _cell.peopleImageViewLeft.image = [UIImage imageCompressWithSimple:pfLeftImageview.image
                                                     scaledToSizeWidth:400.0f
                                                    scaledToSizeHeight:400.0f];

    
    
    
    //設定大頭照圓形
    _cell.postHeadImageView = [UIImageView imageViewWithClipCircle: _cell.postHeadImageView];
    PFImageView *headPFimageView = [[PFImageView alloc] init];
    headPFimageView.image = [UIImage imageNamed:@"photo-placeholder.png"];
    //parse資料
    [headPFimageView setFile:_pe.focusUserALlPicts[_myIndexPath.section][@"userPID"][@"headPhoto"]];
    //縮圖
    _cell.postHeadImageView.image = [UIImage imageCompressWithSimple:headPFimageView.image
                                                   scaledToSizeWidth:40.0f
                                                  scaledToSizeHeight:40.0f];
    //發佈人姓名
    _cell.postName.text = _pe.focusUserALlPicts[_myIndexPath.section][@"userPID"][@"displayName"];
    //發佈日期-->NSDate轉字符串
    NSDate *postDate = [_pe.focusUserALlPicts[_myIndexPath.section] createdAt];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *currentDateString = [dateFormatter stringFromDate:postDate];
    _cell.postDate.text = currentDateString;
    
    //留言的數量-NSNumber轉NSString
    _cell.messageNums.text = [_pe.focusUserALlPicts[_myIndexPath.section][@"messageNumbers"] stringValue];
    //喜歡數量
    _cell.likeNums.text= [_pe.focusUserALlPicts[_myIndexPath.section][@"likeNumbers"] stringValue];
    
    PFUser *meUser = [PFUser currentUser];
    NSString *outcome = _pe.focusUserALlPicts[_myIndexPath.section][meUser.objectId];
    //判斷目前user是否喜歡該張照片，如果是則是實心的，如果不是則是空心的
    if ([outcome isEqualToString:@"yes"]) {
        [_cell.likeBtn setImage:[UIImage imageNamed:@"love.png"] forState:UIControlStateNormal];
    }else{
        [_cell.likeBtn setImage:[UIImage imageNamed:@"love 2.png"] forState:UIControlStateNormal];
    }
    
    
    //點擊MessageBtn
    [_cell.messageBtn addTarget:self action:@selector(messagePress:) forControlEvents:UIControlEventTouchUpInside];
    //messageButton的tag
    _cell.messageBtn.tag = _myIndexPath.section;
    //點擊like
    [_cell.likeBtn addTarget:self action:@selector(likePress:) forControlEvents:UIControlEventTouchUpInside];
    //likeButton的tag
    _cell.likeBtn.tag = _myIndexPath.section;
    
    [_pfImageview loadInBackground];
    [headPFimageView loadInBackground];
}

//點擊留言按鈕
-(void)messagePress:(UIButton*)sender{
    MessageVCon *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"messageStoryBoard"];
    vc.selectPhotoObj = _pe.focusUserALlPicts[sender.tag];
    [self.navigationController pushViewController:vc animated:YES];
}

//點擊喜歡按鈕
-(void)likePress:(UIButton*)sender{
    
    //create sub thread-1
    dispatch_queue_t bg1 = dispatch_queue_create("bg1", nil);
    dispatch_async(bg1, ^{
        //更換喜歡圖片
        PFUser *meUser = [PFUser currentUser];
        NSString *outcome = _pe.focusUserALlPicts[sender.tag][meUser.objectId];
        
        //判斷目前user是否喜歡該張照片
        if ([outcome isEqualToString:@"yes"]) {
            [sender setImage:[UIImage imageNamed:@"love 2.png"] forState:UIControlStateNormal];
            
            [_pe.focusUserALlPicts[sender.tag] incrementKey:@"likeNumbers" byAmount:@-1];
            [_pe.focusUserALlPicts[sender.tag] setObject:@"no" forKey:[meUser objectId]];
            //刪除Like集合裡喜歡的照片
            [NSObject removeFocusUserLikeWithPhotoID:[_pe.focusUserALlPicts[sender.tag] objectId]
                                          withUserID:meUser.objectId completions:nil];
        }else{
            [_pe.focusUserALlPicts[sender.tag] incrementKey:@"likeNumbers"];
            [_pe.focusUserALlPicts[sender.tag] setObject:@"yes" forKey:[meUser objectId]];
            [sender setImage:[UIImage imageNamed:@"love.png"] forState:UIControlStateNormal];
            [NSObject saveOneObjectWithClassName:@"Likes"
                                     complection:^(PFObject *pfObject) {
                                         //likes-userID欄位
                                         [pfObject setObject:meUser.objectId forKey:@"userID"];
                                         //likes-photoID欄位
                                         [pfObject setObject:[_pe.focusUserALlPicts[sender.tag] objectId] forKey:@"photoID"];
                                         [pfObject saveInBackground];
                                     }];
        }
        
        //局部section-->判斷tag
        NSInteger rowTag = 2;
        if (sender.tag != 0 ){
            rowTag = 1;
        }
        //取得主線程(main thread)
        dispatch_async(dispatch_get_main_queue(), ^{
            //局部section刷新
            NSIndexPath *te=[NSIndexPath indexPathForRow:rowTag inSection:sender.tag];
            //開始刷新
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:te,nil]
                                  withRowAnimation:UITableViewRowAnimationNone];
        });
        
        //save in parse to Photos
        [_pe.focusUserALlPicts[sender.tag] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            //取得照片的all info
            [_pe getParseData:^(NSMutableArray *pfObject) {
                //Notification Center
                [[NSNotificationCenter defaultCenter] postNotificationName:PEOPLE_OK object:nil];
            }];
        }];
    });
}



//Left ImageView的Tap手勢的行為
-(void)leftTapMotion:(UIGestureRecognizer*)sender{
    MessageVCon *messageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"messageStoryBoard"];
    [self.navigationController pushViewController:messageViewController animated:YES];
}

//HeadView放大縮小效果-->第三方庫
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_stretchableTableHeaderView scrollViewDidScroll:scrollView];
}
//HeadView放大縮小效果-->第三方庫
- (void)viewDidLayoutSubviews{
    [_stretchableTableHeaderView resizeView];
}

//隱藏狀態列
- (BOOL)prefersStatusBarHidden{
    return YES;
}

@end
