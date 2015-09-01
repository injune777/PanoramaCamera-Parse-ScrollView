
#import "FancyTBViewCell.h"

@interface FancyTBViewCell()

@property (nonatomic, assign) BOOL check;

@end


@implementation FancyTBViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

//TableViewCell的重用
-(void)prepareForReuse{

    //這裡一定要設nil。不然畫面依然會存在那一張placeHolder
    _fancyImageView.image = nil;
    _personalImageView.image = nil;
    _likeImage.image = nil;
    _likeNumbers.text = nil;
    _postState.text = nil;
}
@end
