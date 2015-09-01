
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

//???
#define PEOPLE_OK @"PEOPLE_OK"

@interface MePersonalPageVCon : UIViewController

//被選擇的people PFObject
@property (nonatomic, strong) PFObject *selectPhotoObj;

@end
