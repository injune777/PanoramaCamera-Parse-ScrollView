
#import "MessageTBViewCell.h"

@implementation MessageTBViewCell

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

//TableViewCell的重用
-(void)prepareForReuse{
    _messagerNameLbl.text = nil;
}

@end
