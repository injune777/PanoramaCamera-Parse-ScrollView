
#import "PicWallCollectionVC.h"
#import "PicWallCollectionCell.h"
#import "MessageVCon.h"

#import "UIImage+CustomUIImageEffect.h"

//parse and facebook 登入
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>


#import "ParseDBSource.h"
#import "NSObject+SearchParse.h"

#import "FBLikeLayout.h"

@interface PicWallCollectionVC ()<UIScrollViewDelegate, UIGestureRecognizerDelegate,UICollectionViewDelegateFlowLayout>
//Tap手勢-->跳出照片
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesturePicture;
@property (strong, nonatomic) PicWallCollectionCell *cell;
//Tap手勢-->Go to MessageViewController
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapToOtherViewController;
//ParseDBSingleTon
@property(nonatomic, strong) ParseDBSource *pe;

@end



@implementation PicWallCollectionVC

//不規則佈局
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if(![self.collectionView.collectionViewLayout isKindOfClass:[FBLikeLayout class]]){
        FBLikeLayout *layout = [FBLikeLayout new];
        layout.minimumInteritemSpacing = 4;
        layout.singleCellWidth = (MIN(self.collectionView.bounds.size.width, self.collectionView.bounds.size.height)-self.collectionView.contentInset.left-self.collectionView.contentInset.right-8)/3.0;
        layout.maxCellSpace = 3;
        layout.forceCellWidthForMinimumInteritemSpacing = YES;
        layout.fullImagePercentageOfOccurrency = 50;
        self.collectionView.collectionViewLayout = layout;
        [self.collectionView reloadData];
    } else {
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //Parse singleton 初始化
    _pe = [ParseDBSource shared];
    
    //MESSAGE notification center
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageOK:)
                                                 name:MESSAGE_OK object:nil];
    
    //不規則佈局
    self.collectionView.contentInset = UIEdgeInsetsMake(4, 4, 4, 4);


}
//MESSAGE notification center
-(void)messageOK:(NSNotification*)notification{
    NSLog(@"MESSAGE_OK完成同步");
    [self.collectionView reloadData];
}



#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_pe.parseData count];
}
//customer cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"cell0";
    _cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    //手勢初始化
    [self initGesture];
    
    //原圖的縮略圖==>placeHolder
    PFFile *thumbnail = _pe.parseData[indexPath.row][@"photo"];
    NSData *imageData = [thumbnail getData];
    UIImage *thumbnailImage = [UIImage imageWithData:imageData];
    PFImageView *pfImageview = [[PFImageView alloc] init];
    pfImageview.image = thumbnailImage;
    pfImageview.file = _pe.parseData[indexPath.row][@"photo"];
    //縮圖
//    _cell.picWallImage.image = [UIImage imageCompressWithSimple:pfImageview.image
//                                              scaledToSizeWidth:300.0f
//                                             scaledToSizeHeight:300.0f];
    
    _cell.picWallImage.image = pfImageview.image;
    [pfImageview loadInBackground];
    return _cell;
}


//隱藏NavigationBar-->delegate
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if (velocity.y >0) {
        self.navigationController.navigationBarHidden = YES;
    }else{
        self.navigationController.navigationBarHidden = NO;
    }
}


//手勢初始化
-(void) initGesture{
    _tapGesturePicture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                      action:@selector(tapGesturePicture:)];
    _tapToOtherViewController = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(tapToOtherViewController:)];
    _tapGesturePicture.numberOfTapsRequired = 2;
    _tapToOtherViewController.numberOfTapsRequired = 1;
    //如果不加下面的话，当单指双击时，会先调用单指单击中的处理，再调用单指双击中的处理
    [_tapToOtherViewController requireGestureRecognizerToFail:_tapGesturePicture];
    
    [_cell.picWallImage addGestureRecognizer:_tapGesturePicture];
    [_cell.picWallImage addGestureRecognizer:_tapToOtherViewController];
}
//tapGesturePicture
-(void)tapGesturePicture:(UIGestureRecognizer*)sender{
    UIImageView *selectedImageView=(UIImageView*)[sender view];
    //取得NSIndexPath-->使用刺件的父物件的方法-->這裡是Contentview
    NSIndexPath *myIndexPath = [self.collectionView indexPathForCell:(PicWallCollectionCell*)[[selectedImageView superview] superview]];
    //轉型為PicWallCollectionCell
    PicWallCollectionCell *customCell =(PicWallCollectionCell*)[self.collectionView cellForItemAtIndexPath:myIndexPath];
     [UIImage createTapPictureJTSImageViewController:customCell.picWallImage.image withInputImageView:customCell.picWallImage withInputViewController:self];
}
//tapToOtherViewController
-(void)tapToOtherViewController:(UIGestureRecognizer*)sender{
    MessageVCon *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"messageStoryBoard"];
    //取得NSIndexPath-->使用刺件的父物件的方法
    UIImageView *selectedImageView=(UIImageView*)[sender view];
    NSIndexPath *myIndexPath = [self.collectionView indexPathForCell:
                                (PicWallCollectionCell *)[[selectedImageView superview] superview]];
    //傳選擇的photo物件-->選擇的照片物件
    vc.selectPhotoObj = _pe.parseData[myIndexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}


//不規則佈局
-(CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    //原圖的縮略圖==>placeHolder
    PFFile *thumbnail = _pe.parseData[indexPath.row][@"photo"];
    NSData *imageData = [thumbnail getData];
    UIImage *thumbnailImage = [UIImage imageWithData:imageData];
    return thumbnailImage.size;
}


@end
