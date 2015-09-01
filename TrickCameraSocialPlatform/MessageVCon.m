
#import "MessageVCon.h"
#import "MessageTBViewCell.h"
#import "ParallaxHeaderView.h"
#import "UIImage+ImageEffects.h"

#import "UIImageView+ClipAndspecific.h"
#import "UIImage+CustomUIImageEffect.h"

//點擊照片
#import "JTSImageInfo.h"
#import "JTSImageViewController.h"

//parse and facebook 登入
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#import "ParseDBSource.h"
#import "NSObject+SaveParse.h"
#import "FancyTBViewCon.h"
#import "PeoplesVCon.h"

@interface MessageVCon ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate,
UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *messagesTextField;
@property (weak, nonatomic) IBOutlet UIButton *postMessageBtn;

//customerCell
@property (strong, nonatomic) MessageTBViewCell *cell;

//手勢物件
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapPictureGesture;

//Parse用物件
@property(nonatomic, strong) PFImageView *pfImageview;
@property(nonatomic, strong) ParseDBSource *pe;
@property(nonatomic, strong) NSMutableArray *allMessageAry;

@end



@implementation MessageVCon

- (void)viewDidLoad {
    [super viewDidLoad];
    //隱藏TabBar
    [self.tabBarController.tabBar setHidden:YES];

    //原圖的縮略圖==>placeHolder
    PFFile *thumbnail = _selectPhotoObj[@"photo"];
    NSData *imageData = [thumbnail getData];
    UIImage *thumbnailImage = [UIImage imageWithData:imageData];
    
    _pfImageview = [[PFImageView alloc] init];
    _pfImageview.image = thumbnailImage;
    //指定照片
    [_pfImageview setFile:_selectPhotoObj[@"photo"]];
     //縮圖
    _headerView.headerImage = [UIImage imageCompressWithSimple:_pfImageview.image scaledToSizeWidth:300.0f
                                                    scaledToSizeHeight:300.0f];
    //設定ParallaxHeaderView-->TableView Headerivew模糊效果
    _headerView = [ParallaxHeaderView parallaxHeaderViewWithImage:_pfImageview.image
                                                          forSize:CGSizeMake(self.tableView.frame.size.width, 250)];
    //圖片標題
    //_headerView.headerTitleLabel.text = @"Life is either a daring adventure";
    [self.tableView setTableHeaderView:_headerView];

    //初始化TapGesture的
    _tapPictureGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPictureMotion:)];
    [_headerView addGestureRecognizer:_tapPictureGesture];

    
    //Message TextView-->Custmoer
    [[self.messagesTextField layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.messagesTextField layer] setBorderWidth:1];
    

    //監聽鍵盤高度變化
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:@"UIKeyboardWillShowNotification"
                                               object:nil];
    //監聽鍵盤高度變化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    //自適化TableViewCell高度
    self.tableView.estimatedRowHeight = 44.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    
    //消去TableView最後沒用到的欄位的分隔線
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    _pe = [ParseDBSource shared];
    //選擇照片的 photo id
    _allMessageAry = [_pe.allPhotoAndMessages objectForKey:_selectPhotoObj.objectId];
}


//向上移動時的模糊效果
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [(ParallaxHeaderView *)self.tableView.tableHeaderView refreshBlurViewForNewImage];
}
//更新
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

//Section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//Row
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //返回留言筆數
    return [_allMessageAry count];
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     _cell = [tableView dequeueReusableCellWithIdentifier:@"cell0" forIndexPath:indexPath];
     _cell.theMessageLbl.text = _allMessageAry[indexPath.row][@"message"];
     
      //留言者姓名
     _cell.messagerNameLbl.text = _allMessageAry[indexPath.row][@"userPID"][@"displayName"];
     
     //NSDate轉字符串-->發佈日期
     NSDate *postDate = [_allMessageAry[indexPath.row] createdAt];
     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
     [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
     NSString *currentDateString = [dateFormatter stringFromDate:postDate];
     _cell.postDate.text = currentDateString;
     
     //設定大頭照
     //Poster的頭像->栽成圓形
     _cell.messagerPersonalPic = [UIImageView imageViewWithClipCircle: _cell.messagerPersonalPic];
     PFImageView *headPFimageView = [[PFImageView alloc] init];
     
     //原圖的縮略圖==>placeHolder
     PFFile *thumbnail = _allMessageAry[indexPath.row][@"userPID"][@"headPhoto"];
     NSData *imageData = [thumbnail getData];
     UIImage *thumbnailImage = [UIImage imageWithData:imageData];
     headPFimageView.image = thumbnailImage;
     [headPFimageView setFile:_allMessageAry[indexPath.row][@"userPID"][@"headPhoto"]];
     //縮圖
      [headPFimageView loadInBackground];
     _cell.messagerPersonalPic.image = [UIImage imageCompressWithSimple:headPFimageView.image
                                                      scaledToSizeWidth:150.0f
                                                   scaledToSizeHeight:150.0f];
    
     //Label字體加粗
     [_cell.messagerNameLbl setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
     //Label對齊方式-最後一行自然對齊
     _cell.theMessageLbl.textAlignment = NSTextAlignmentJustified;
     return _cell;
}

//Scroll Delegate-->headerView的彈黃效果
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.tableView) {
        [(ParallaxHeaderView*)self.tableView.tableHeaderView
         layoutHeaderViewForScrollViewOffset:scrollView.contentOffset];
    }
}


//隱藏鍵盤-->TextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
//鍵盤Appear時的NotificationCenter
- (void) keyboardWillShow:(NSNotification *)note {
    //取得鍵盤高度
    NSDictionary *info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    //获取myView的位置
    CGRect frame = self.view.frame;
    //根据slider的值动态的设置myView的坐标和宽高，设置的时候view中心不变
    frame.origin.x = 0;
    frame.origin.y = -kbSize.height;
    frame.size.height = self.view.frame.size.height;
    frame.size.width = self.view.frame.size.width;
    //更新myView的位置
    self.view.frame = frame;
}
//鍵盤Disappear時的NotificationCenter
-(void)keyboardWillHide:(NSNotification *)note{
    CGRect frame = self.view.frame;
    //根据slider的值动态的设置myView的坐标和宽高，设置的时候view中心不变
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.height = self.view.frame.size.height;
    frame.size.width = self.view.frame.size.width;
    //更新myView的位置
    self.view.frame = frame;
}



//每列被選擇時
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PeoplesVCon *peoplePageController = [self.storyboard instantiateViewControllerWithIdentifier:@"PeoplePage"];
    
    //傳PFUser物件過去
    peoplePageController.selectPhotoObj = _allMessageAry[indexPath.row][@"userPID"];
    //傳到第三個頁面的userID
    [self.navigationController pushViewController:peoplePageController animated:YES];
}



//往上滑動時隱藏NavigationBar-->delegate
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if (velocity.y >0) {
        self.navigationController.navigationBarHidden = YES;
    }else{
        self.navigationController.navigationBarHidden = NO;
    }
}



//留言button
- (IBAction)postMessage:(id)sender {
    PFObject *obj = [PFObject objectWithClassName:@"Messages"];
    PFUser *currentUser = [PFUser currentUser];
    //留言信息
    [obj setObject:_messagesTextField.text forKey:@"message"];
    _messagesTextField.text = nil;
    //因為是pointer型別，所以要存整個物件
    [obj setObject:currentUser forKey:@"userPID"];
    [obj setObject:_selectPhotoObj.objectId forKey:@"photoID"];
    [_allMessageAry insertObject:obj atIndex:0];
    
    //插入第一個section，第一個row
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [indexPaths addObject: indexPath];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
    //create sub thread -1
    dispatch_queue_t bg1 = dispatch_queue_create("bg1", nil);
    dispatch_async(bg1, ^{
        [obj saveInBackground];
        
        //留言數量加1
        [_selectPhotoObj incrementKey:@"messageNumbers"];
        [_selectPhotoObj saveInBackground];
        
        //取得照片的all info
        [_pe getParseData:^(NSMutableArray *pfObject) {
            NSLog(@"完成更新...");
            //notification center
            //發佈者
            [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_OK object:nil];
        }];
    });
}


//隱藏狀態列
- (BOOL)prefersStatusBarHidden{
    return YES;
}

//點擊照片手勢
-(void)tapPictureMotion:(UIGestureRecognizer*)sender{
    //點擊照片跳出
    [UIImage createTapPictureJTSImageViewController:_pfImageview.image
                                 withInputImageView:nil withInputViewController:self];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    [self.tableView endEditing:YES];
//}



@end
