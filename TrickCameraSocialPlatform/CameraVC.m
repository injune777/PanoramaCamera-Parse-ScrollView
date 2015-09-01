
#import "CameraVC.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^PropertyChangeBlock) (AVCaptureDevice *captureDevice);
@interface CameraVC ()
@property (strong,nonatomic) AVCaptureSession *captureSession;//輸入與輸出設備之間的資訊傳遞
@property (strong,nonatomic) AVCaptureDeviceInput *captureDeviceInput;//從AVCaptureDevice取得資訊
@property (strong,nonatomic) AVCaptureStillImageOutput *captureStillImageOutput;//照片輸出
@property (strong,nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;//相機預覽
@property (weak , nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UIButton *takeButton;//拍照按钮
@property (weak, nonatomic) IBOutlet UIButton *flashAutoButton;//自動閃光
@property (weak, nonatomic) IBOutlet UIButton *flashOnButton;//打開閃光
@property (weak, nonatomic) IBOutlet UIButton *flashOffButton;//關閉閃光
@property (weak, nonatomic) IBOutlet UIImageView *focusCursor; //聚焦光圈
@property (weak, nonatomic) IBOutlet UIImageView *GoPanoView;



@end

@implementation CameraVC
#pragma mark - 控制方法

- (void)viewDidLoad {
    [super viewDidLoad];
}
-(IBAction)backToMain:(UIStoryboardSegue*)segue{    //從這個story board延伸出去的view controller 可追回此viewcontroller
    NSLog(@"backToWhite");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    //初始化
    //    _captureSession=[[AVCaptureSession alloc]init];
    //    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {//設置解析度
    //        _captureSession.sessionPreset=AVCaptureSessionPreset1280x720;
    //    }
    //    //取得輸入設備
    //    AVCaptureDevice *captureDevice=[self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];//取得後鏡頭
    //    if (!captureDevice) {
    //        NSLog(@"獲取後鏡頭有誤.");
    //        return;
    //    }
    //
    //    NSError *error=nil;
    //    //取得輸入資訊
    //    _captureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:&error];
    //    if (error) {
    //        NSLog(@"取得輸入設備有問題，錯誤原因：%@",error.localizedDescription);
    //        return;
    //    }
    //    //取得輸出數據
    //    _captureStillImageOutput=[[AVCaptureStillImageOutput alloc]init];
    //    NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    //    [_captureStillImageOutput setOutputSettings:outputSettings];//输出设置
    //
    //    //添加設備输入
    //    if ([_captureSession canAddInput:_captureDeviceInput]) {
    //        [_captureSession addInput:_captureDeviceInput];
    //    }
    //
    //    //添加設備输出
    //    if ([_captureSession canAddOutput:_captureStillImageOutput]) {
    //        [_captureSession addOutput:_captureStillImageOutput];
    //    }
    //
    //    //建立Camera Preview ,即時畫面
    //    _captureVideoPreviewLayer=[[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    //     UIView *view = [self viewContainer];
    //    CALayer *layer = [view layer];
    ////    CALayer *layer=self.viewContainer.layer;
    //    layer.masksToBounds=YES;
    //    [layer setMasksToBounds:YES];
    //
    //    CGRect bounds = [view bounds];
    //    [_captureVideoPreviewLayer setFrame:bounds];
    //
    ////    _captureVideoPreviewLayer.frame=layer.bounds;
    //    _captureVideoPreviewLayer.frame=view.frame;
    //    _captureVideoPreviewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//填充模式
    //    //_captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResize;
    //    //_captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    //    //將Preview加入
    //    //[layer addSublayer:_captureVideoPreviewLayer];
    //    [layer insertSublayer:_captureVideoPreviewLayer below:self.focusCursor.layer];
    //    [self addNotificationToCaptureDevice:captureDevice]; //通知設備
    //    [self addGenstureRecognizer];//添加手勢
    //    [self setFlashModeButtonStatus];//設置閃光燈按鈕狀態
}
//展示及啟動時 停止session
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //初始化
    _captureSession=[[AVCaptureSession alloc]init];
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {//設置解析度
        _captureSession.sessionPreset=AVCaptureSessionPreset1280x720;
    }
    //取得輸入設備
    AVCaptureDevice *captureDevice=[self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];//取得後鏡頭
    if (!captureDevice) {
        NSLog(@"獲取後鏡頭有誤.");
        return;
    }
    
    NSError *error=nil;
    //取得輸入資訊
    _captureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:&error];
    if (error) {
        NSLog(@"取得輸入設備有問題，錯誤原因：%@",error.localizedDescription);
        return;
    }
    //取得輸出數據
    _captureStillImageOutput=[[AVCaptureStillImageOutput alloc]init];
    NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    [_captureStillImageOutput setOutputSettings:outputSettings];//输出设置
    
    //添加設備输入
    if ([_captureSession canAddInput:_captureDeviceInput]) {
        [_captureSession addInput:_captureDeviceInput];
    }
    
    //添加設備输出
    if ([_captureSession canAddOutput:_captureStillImageOutput]) {
        [_captureSession addOutput:_captureStillImageOutput];
    }
    
    //建立Camera Preview ,即時畫面
    _captureVideoPreviewLayer=[[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    UIView *view = [self viewContainer];
    CALayer *layer = [view layer];
    //    CALayer *layer=self.viewContainer.layer;
    layer.masksToBounds=YES;
    [layer setMasksToBounds:YES];
    
    CGRect bounds = [view bounds];
    [_captureVideoPreviewLayer setFrame:bounds];
    
    //    _captureVideoPreviewLayer.frame=layer.bounds;
    _captureVideoPreviewLayer.frame=view.frame;
    _captureVideoPreviewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//填充模式
    //_captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResize;
    //_captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    //將Preview加入
    //[layer addSublayer:_captureVideoPreviewLayer];
    [layer insertSublayer:_captureVideoPreviewLayer below:self.focusCursor.layer];
    [self addNotificationToCaptureDevice:captureDevice]; //通知設備
    [self addGenstureRecognizer];//添加手勢
    [self setFlashModeButtonStatus];//設置閃光燈按鈕狀態
    [self.captureSession startRunning];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.captureSession stopRunning];
}
#pragma mark - 通知
/**
 *  添加通知
 */
-(void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice{
    
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled=YES;
    }];
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //改變捕捉區域
    [notificationCenter addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
-(void)removeNotificationFromCaptureDevice:(AVCaptureDevice *)captureDevice{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
/**
 *  移除所有通知
 */
-(void)removeNotification{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

-(void)addNotificationToCaptureSession:(AVCaptureSession *)captureSession{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //session error
    [notificationCenter addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:captureSession];
}




//@param notification 通知

-(void)deviceConnected:(NSNotification *)notification{
    NSLog(@"設備已連接...");
}
/**
 *  设备连接断开
 *
 *  @param notification 通知对象
 */
-(void)deviceDisconnected:(NSNotification *)notification{
    NSLog(@"設備已切斷.");
}
/**
 *  捕获区域改变
 *
 *  @param notification 通知对象
 */
-(void)areaChange:(NSNotification *)notification{
    NSLog(@"捕捉區域改變...");
}

/**
 *  会话出错
 *
 *  @param notification 通知对象
 */
-(void)sessionRuntimeError:(NSNotification *)notification{
    NSLog(@"Session Error.");
}

#pragma mark - 自訂方法

/**
 *  取得指定位置的鏡頭
 *
 *  @param position 鏡頭位置
 *
 *  @return 鏡頭硬體
 */
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position]==position) {
            return camera;
        }
    }
    return nil;
}

/**
 *  改變設備屬性的方法
 *
 *  @param propertyChange 屬性改變操作
 */

-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    AVCaptureDevice *captureDevice= [self.captureDeviceInput device];
    NSError *error;if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"改變屬性過程出錯，錯誤訊息：%@",error.localizedDescription);
    }
}

/**
 *  設置閃光模式
 *
 *  @param flashMode 閃光模式
 */
-(void)setFlashMode:(AVCaptureFlashMode )flashMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
    }];
}
/**
 *  設定聚焦模式
 *
 *  @param focusMode 聚焦模式
 */
-(void)setFocusMode:(AVCaptureFocusMode )focusMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
    }];
}
/**
 *  設定曝光模式
 *
 *  @param exposureMode 曝光模式
 */
-(void)setExposureMode:(AVCaptureExposureMode)exposureMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
    }];
}
/**
 *  設定聚焦點
 *
 *  @param point 聚焦點
 */
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}

/**
 *  添加手势，按下时聚焦
 */
-(void)addGenstureRecognizer{
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    [self.viewContainer addGestureRecognizer:tapGesture];
}
-(void)tapScreen:(UITapGestureRecognizer *)tapGesture{
    CGPoint point= [tapGesture locationInView:self.viewContainer];
    //将UI座標轉化为鏡頭坐标
    CGPoint cameraPoint= [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:point];
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

/**
 *  设置閃光按钮状态
 */
-(void)setFlashModeButtonStatus{
    AVCaptureDevice *captureDevice=[self.captureDeviceInput device];
    AVCaptureFlashMode flashMode=captureDevice.flashMode;
    if([captureDevice isFlashAvailable]){
        self.flashAutoButton.hidden=NO;
        self.flashOnButton.hidden=NO;
        self.flashOffButton.hidden=NO;
        self.flashAutoButton.enabled=YES;
        self.flashOnButton.enabled=YES;
        self.flashOffButton.enabled=YES;
        switch (flashMode) {
            case AVCaptureFlashModeAuto:
                self.flashAutoButton.enabled=NO;
                break;
            case AVCaptureFlashModeOn:
                self.flashOnButton.enabled=NO;
                break;
            case AVCaptureFlashModeOff:
                self.flashOffButton.enabled=NO;
                break;
            default:
                break;
        }
    }else{
        self.flashAutoButton.hidden=YES;
        self.flashOnButton.hidden=YES;
        self.flashOffButton.hidden=YES;
    }
}

/**
 *  設置聚焦光圈位置
 *
 *  @param point 光圈位置
 */
-(void)setFocusCursorWithPoint:(CGPoint)point{
    self.focusCursor.center=point;
    self.focusCursor.transform=CGAffineTransformMakeScale(1.5, 1.5);
    self.focusCursor.alpha=1.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.focusCursor.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursor.alpha=0;
        
    }];
}
-(void)dealloc
{
    [self removeNotification];
}
#pragma mark - UI方法
#pragma mark 拍照
- (IBAction)takeButtonClick:(UIButton *)sender {
    //連結輸出設備
    AVCaptureConnection *captureConnection=[self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    //連結設備取得輸出數據
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer) {
            NSData *imageData=[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image=[UIImage imageWithData:imageData];
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            //            ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
            //            [assetsLibrary writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
        }
        
    }];
}
#pragma mark 切换前後鏡頭
- (IBAction)toggleButtonClick:(UIButton *)sender {
    AVCaptureDevice *currentDevice=[self.captureDeviceInput device];
    AVCaptureDevicePosition currentPosition=[currentDevice position];
    [self removeNotificationFromCaptureDevice:currentDevice];
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition=AVCaptureDevicePositionFront;
    if (currentPosition==AVCaptureDevicePositionUnspecified||currentPosition==AVCaptureDevicePositionFront) {
        toChangePosition=AVCaptureDevicePositionBack;
    }
    toChangeDevice=[self getCameraDeviceWithPosition:toChangePosition];
    [self addNotificationToCaptureDevice:toChangeDevice];
    //取得設備對象
    AVCaptureDeviceInput *toChangeDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:toChangeDevice error:nil];
    
    [self.captureSession beginConfiguration];
    //移除原有輸入對象
    [self.captureSession removeInput:self.captureDeviceInput];
    //添加新的输入對象
    if ([self.captureSession canAddInput:toChangeDeviceInput]) {
        [self.captureSession addInput:toChangeDeviceInput];
        self.captureDeviceInput=toChangeDeviceInput;
    }
    //提交配置
    [self.captureSession commitConfiguration];
    
    [self setFlashModeButtonStatus];
}

#pragma mark 開啟自動閃光
- (IBAction)flashAutoClick:(UIButton *)sender {
    [self setFlashMode:AVCaptureFlashModeAuto];
    [self setFlashModeButtonStatus];
}
#pragma mark 打開閃光
- (IBAction)flashOnClick:(UIButton *)sender {
    [self setFlashMode:AVCaptureFlashModeOn];
    [self setFlashModeButtonStatus];
}
#pragma mark 關閉閃光
- (IBAction)flashOffClick:(UIButton *)sender {
    [self setFlashMode:AVCaptureFlashModeOff];
    [self setFlashModeButtonStatus];
}



@end