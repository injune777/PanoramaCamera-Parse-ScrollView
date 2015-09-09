
#import "FollowTB.h"
#import "FollowCell.h"

//parse and facebook 登入
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKGraphRequestConnection.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import "PFLogInViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "UIImageView+ClipAndspecific.h"

#import "NSObject+SearchParse.h"

@interface FollowTB ()

@end

@implementation FollowTB

- (void)viewDidLoad {
    [super viewDidLoad];

}



#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_followArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FollowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    
    cell.nameLbl.text = _followArray[indexPath.row][@"followering"][@"displayName"];
    
    
    //設定大頭照
    PFImageView *headPFimageView = [[PFImageView alloc] init];
    //原圖的縮略圖==>placeHolder
    PFFile *thumbnail_head = _followArray[indexPath.row][@"followering"][@"headPhoto"];
    NSData *imageData_head = [thumbnail_head getData];
    UIImage *thumbnailImage_head = [UIImage imageWithData:imageData_head];
    headPFimageView.image = thumbnailImage_head;
    [headPFimageView setFile:_followArray[indexPath.row][@"followering"][@"headPhoto"]];
    cell.headImageView = [UIImageView imageViewWithClipCircle:cell.headImageView];
    cell.headImageView.image = headPFimageView.image;
    
    
    dispatch_queue_t bg1 = dispatch_queue_create("bg1", nil);
    dispatch_async(bg1, ^{
        PFUser *currentUser = [PFUser currentUser];
        [NSObject getFoucsUserIsOtherUserFollowerWithUserID:currentUser
                                            withOtherUserID:_followArray[indexPath.row][@"followering"]
                                                 completion:^(BOOL completion) {
                                                     //取得主線程(main thread)
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         if (completion == YES) {
                                                             cell.statusLbl.image = [UIImage imageNamed:@"yesFollow.png"];
                                                         }else{
                                                             cell.statusLbl.image = [UIImage imageNamed:@"notFollow.png"];
                                                         }
                                                     });
                                                     
                                                 }];
    });
    
    
    
    return cell;
}



@end
