
#import "MePersonalPageTBCell.h"

@implementation MePersonalPageTBCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

//TableViewCell的重用
-(void)prepareForReuse
{
    _peopleImageViewLeft.image = nil;
    
    
}

@end
