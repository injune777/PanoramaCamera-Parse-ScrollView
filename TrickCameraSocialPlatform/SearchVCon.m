
#import "SearchVCon.h"
#import "SearchTBCell.h"

#import "UIImage+CustomUIImageEffect.h"
#import "UIImageView+ClipAndspecific.m"


@interface SearchVCon ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) SearchTBCell *cell;
//從storyboard上面的TableView拉過來聯結，才會生效
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//手勢
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapImageChangeStatus;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UIImageView *centerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;


@end

@implementation SearchVCon

- (void)viewDidLoad {
    [super viewDidLoad];
    //自適化TableViewCell高度
    self.tableView.estimatedRowHeight = 44.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    _leftImageView = [UIImageView imageViewWithClipCircle:_leftImageView];
    _centerImageView = [UIImageView imageViewWithClipCircle:_centerImageView];
    _rightImageView = [UIImageView imageViewWithClipCircle:_rightImageView];
    
    _tapImageChangeStatus = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
}



//點擊Iimage手勢改變好友狀態
-(void)tapPictureMotion:(UIGestureRecognizer*)sender{
    UIImageView *selectedImageView=(UIImageView*)[sender view];
    NSLog(@"%ld", selectedImageView.tag);

}


//Section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//Row
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

//customer cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    _cell = [tableView dequeueReusableCellWithIdentifier:@"cell0" forIndexPath:indexPath];
    _cell.personNameLbl.text = @"Mytest";
    _cell.searchPersonImageView = [UIImageView imageViewWithClipCircle:_cell.searchPersonImageView];
    _cell.searchPersonImageView.image = [UIImage imageCompressWithSimple:[UIImage imageNamed:@"yangHead.jpg"]
                                                       scaledToSizeWidth:100.0f scaledToSizeHeight:100.0f];
    
    _cell.statusImageView.image = [UIImage imageNamed:@"searchStatus.png"];
    return _cell;
}





@end
