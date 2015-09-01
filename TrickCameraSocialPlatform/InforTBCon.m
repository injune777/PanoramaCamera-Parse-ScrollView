
#import "InforTBCon.h"
#import "InforTBCell.h"

#import "UIImage+CustomUIImageEffect.h"
#import "UIImageView+ClipAndspecific.m"

//parse and facebook 登入
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>



@interface InforTBCon ()

@property(nonatomic, strong) InforTBCell *cell;
@property(nonatomic, strong) NSMutableArray *parseData;

@end

@implementation InforTBCon

- (void)viewDidLoad {
    [super viewDidLoad];
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Connect custom cell
    _cell = [tableView dequeueReusableCellWithIdentifier:@"cell0" forIndexPath:indexPath];
    //栽剪成圓形
    _cell.peopleImageView = [UIImageView imageViewWithClipCircle:_cell.peopleImageView];
    //縮圖
    _cell.peopleImageView.image = [UIImage imageCompressWithSimple:[UIImage imageNamed:@"yangHead.jpg"]
                                                 scaledToSizeWidth:150.0f scaledToSizeHeight:150.0f];
    _cell.informationLbl.text = @"MyTest已追蹤您...";
    return _cell;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



@end
