
#import <Foundation/Foundation.h>

@protocol CustomProtocol <NSObject>

//必須實現的方法
@required
//契約條文
-(void) passValueFromTextField:(NSString*)textFieldString;


@end
