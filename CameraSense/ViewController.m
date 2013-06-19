//
//  ViewController.m
//  CameraSense
//
//  Created by Lloyd Hughes on 2013/03/28.
//  Copyright (c) 2013 Lloyd Hughes. All rights reserved.
//

#import "ViewController.h"
#import "CMMotionManagerSim.h"
#import "GPUImageFASTCornerDetectorFilter.h"

int cnt;

@interface ViewController ()
{
    GPUImageVideoCamera *videoCamera;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageFASTCornerDetectorFilter *FASTfilter;
    GPUImageShiTomasiFeatureDetectionFilter *CornerDetect;
    GPUImageMovieWriter *movieWriter;
    dispatch_queue_t fqueue;
    NSFileManager* filemgr;
}
@property (strong, nonatomic) CMMotionManager  *motionManager;
@property (strong, nonatomic) NSOperationQueue *queue;
//@property (nonatomic, retain) AVCaptureSession *session;
//@property (nonatomic, retain) AVCaptureDevice *camera;
//@property (nonatomic, retain) AVCaptureDeviceInput *cameraStream;
//@property (nonatomic, retain) AVCaptureVideoDataOutput *outputStream;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *videoLayer;
//@property (nonatomic, retain) NSMutableArray *bufferArray;
@property (nonatomic, strong) NSString *root;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    cnt = 0;
    
    fqueue = dispatch_queue_create("File Queue", DISPATCH_QUEUE_SERIAL);
    
    NSArray *dirPaths;
    NSString *docsDir;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                   NSUserDomainMask, YES);
    self.root = [dirPaths objectAtIndex:0];

    self.motionManager = [[CMMotionManager alloc] init];
    self.queue = [[NSOperationQueue alloc] init];
    
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    filter = [[GPUImageBrightnessFilter alloc] init];
    [(GPUImageBrightnessFilter *)filter setBrightness:0.0];
    
    FASTfilter = [[GPUImageFASTCornerDetectorFilter alloc] init];
    CornerDetect = [[GPUImageShiTomasiFeatureDetectionFilter alloc] init];
      
    [videoCamera addTarget:filter];
    //[filter addTarget:FASTfilter];
    
    [FASTfilter setupFilterForSize:CGSizeMake(480.0, 640.0)];
//    
//    GPUImageCrosshairGenerator *crosshairGenerator = [[GPUImageCrosshairGenerator alloc] init];
//    crosshairGenerator.crosshairWidth = 15.0;
//    [crosshairGenerator forceProcessingAtSize:CGSizeMake(480.0, 640.0)];
//
//    [CornerDetect setCornersDetectedBlock:^(GLfloat* cornerArray, NSUInteger cornersDetected, CMTime frameTime){
//        
//        [crosshairGenerator renderCrosshairsFromArray:cornerArray count:cornersDetected frameTime:frameTime];
//        NSLog(@"corners: %u", cornersDetected);
//        
//    }];
//    
//    GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
//    [blendFilter forceProcessingAtSize:CGSizeMake(480.0, 640.0)];
    
    GPUImageView *filterView = [[GPUImageView alloc] init];
    [filter addTarget:filterView];
    
//    [videoCamera addTarget:blendFilter];
//    [filter addTarget:CornerDetect];
//    [crosshairGenerator addTarget:blendFilter];
   
//    self.session = [[AVCaptureSession alloc] init];
//       
//    self.session.sessionPreset = AVCaptureSessionPreset640x480;
//    
//    self.camera = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
//    
//    NSError *error = [NSError alloc];
//    self.cameraStream = [AVCaptureDeviceInput deviceInputWithDevice:self.camera error:&error];
//    
//    if ([self.session canAddInput:self.cameraStream])
//        [self.session addInput:self.cameraStream];
//   
//    self.videoLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:videoCamera.captureSession];
//    
//    [self.videoLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    CALayer *rootLayer = [[self view] layer];
    [rootLayer setMasksToBounds:YES];
   
    [filterView setFrame:rootLayer.bounds];
    [rootLayer insertSublayer:filterView.layer atIndex:0];
    
    [videoCamera startCameraCapture];
        
//
//    self.outputStream = [[AVCaptureVideoDataOutput alloc]init];
//    self.outputStream.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_24BGR]
//                                                                  forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
//    [self.outputStream setAlwaysDiscardsLateVideoFrames:YES];
//    
//    if ([self.session canAddOutput:self.outputStream ])
//        [self.session addOutput:self.outputStream];
//    
//    dispatch_queue_t queue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL);
//    [self.outputStream setSampleBufferDelegate:self queue:queue];
//    
//    [self.session startRunning];
}

- (void) frameAboutToWrite:(CMTime)frameTime
{
    cnt++;
    NSMutableData *data = [NSMutableData alloc];
    
    NSString *msg = [NSString stringWithFormat:@"FRAME %lld\nACC0, X:%.6f, Y:%.6f, Z:%.6f\nGYR0, X:%.6f, Y:%.6f, Z:%.6f\nMAG0, X:%.6f, Y:%.6f, Z:%.6f\n",frameTime.value,self.motionManager.accelerometerData.acceleration.x,
                     self.motionManager.accelerometerData.acceleration.y,self.motionManager.accelerometerData.acceleration.z,self.motionManager.gyroData.rotationRate.x,
                     self.motionManager.gyroData.rotationRate.y,self.motionManager.gyroData.rotationRate.z,self.motionManager.magnetometerData.magneticField.x,
                     self.motionManager.magnetometerData.magneticField.y,self.motionManager.magnetometerData.magneticField.z];
    
    CMAttitude *at = self.motionManager.deviceMotion.attitude;
    CMAcceleration acc = self.motionManager.deviceMotion.userAcceleration;
    CMAcceleration g = self.motionManager.deviceMotion.gravity;
    
    msg = [NSString stringWithFormat:@"%@ROT MATRIX\n%.6f %.6f %.6f\n%.6f %.6f %.6f\n%.6f %.6f %.6f\n", msg, at.rotationMatrix.m11, at.rotationMatrix.m12, at.rotationMatrix.m13,
                                                                                            at.rotationMatrix.m21, at.rotationMatrix.m22, at.rotationMatrix.m23,
                                                                                            at.rotationMatrix.m31, at.rotationMatrix.m32, at.rotationMatrix.m33];
    
    msg = [NSString stringWithFormat:@"%@QUATERNION\n%.6f %.6f %.6f %.6f\nUSRACC0, X:%.6f, Y:%.6f, Z:%.6f\nGACC0, X:%.6f, Y:%.6f, Z:%.6f\n", msg, at.quaternion.x, at.quaternion.y, at.quaternion.z, at.quaternion.w, acc.x, acc.y, acc.z, g.x, g.y, g.z];
    
    [self.gyroLabel performSelectorOnMainThread:@selector(setText:) withObject:msg waitUntilDone:NO];
    
    [data appendData:[msg dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSString* name = [self.root stringByAppendingPathComponent:[NSString stringWithFormat:@"Sensors/frame%u.txt",cnt]];
    
    NSLog(name);
    
    dispatch_async(fqueue, ^{
        [data writeToFile:name atomically:NO];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)stopCapture:(id)sender {
//    [self.session stopRunning];
    [filter removeTarget:movieWriter];
    [movieWriter finishRecording];
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopDeviceMotionUpdates];
    [self.motionManager stopGyroUpdates];
    [self.motionManager stopMagnetometerUpdates];
}

- (IBAction)startCapture:(id)sender {

    filemgr = [NSFileManager defaultManager];
    [filemgr removeItemAtPath:[NSString stringWithFormat:@"%@/Sensors/",self.root] error:nil];
    [filemgr createDirectoryAtPath:[NSString stringWithFormat:@"%@/Sensors/",self.root] withIntermediateDirectories:NO attributes:nil error:nil];
        
    NSString *pathToMovie = [NSString stringWithFormat:@"%@/Movie.m4v",self.root];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
    
    movieWriter.delegate = self;
    [filter addTarget:movieWriter];
    
    [videoCamera startCameraCapture];
    
    cnt = 0;
    
    if (self.motionManager.accelerometerAvailable){
        
        self.motionManager.accelerometerUpdateInterval = 1.0/60.0;
        [self.motionManager startAccelerometerUpdates];
        
    } else {
        [self.accelLabel setText:@"This device does not have an accelerometer"];
    }
    
    if (self.motionManager.gyroAvailable){
        
        self.motionManager.gyroUpdateInterval = 1.0/60.0;
        [self.motionManager startGyroUpdates];
        
    } else {
        [self.accelLabel setText:@"This device does not have an gyroscope"];
    }
    
    if (self.motionManager.magnetometerAvailable){
        
        self.motionManager.magnetometerUpdateInterval = 1.0/60.0;
        [self.motionManager startMagnetometerUpdates];
        
    } else {
        [self.magLabel setText:@"This device does not have an magnemometer"];
    }
    
    if (self.motionManager.deviceMotionAvailable){
        self.motionManager.deviceMotionUpdateInterval = 1.0/60.0;
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical];
    } else {
        [self.magLabel setText:@"This device cannot capture Device Motion"];
    }
    
    [movieWriter startRecording];
    
}

- (BOOL)textFieldShouldReturn:(UITextField*)theTextField {
    return YES;
}

//- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
//{
//    CVImageBufferRef frameBuf = CMSampleBufferGetImageBuffer(sampleBuffer);
//        
//    CVPixelBufferLockBaseAddress(frameBuf, 0);
//    
//    frameBuf = CVPixelBufferRetain(frameBuf);
//    
//    size_t width = CVPixelBufferGetWidthOfPlane(frameBuf,0);
//    size_t height = CVPixelBufferGetHeightOfPlane(frameBuf,0);
//    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(frameBuf,0);
//    
//    uint8_t *grayBuf = CVPixelBufferGetBaseAddressOfPlane(frameBuf, 0);
//    
//    NSData *tmp = [[NSData alloc] initWithBytes:grayBuf length:height*bytesPerRow];
//
//    NSMutableData *data = [NSMutableData alloc];
//    
//    NSString* msg;
//    
//    cnt++;
//
//    msg = [NSString stringWithFormat:@"\nFRAME %u\nACC0, X:%.6f, Y:%.6f, Z:%.6f\nGYR0, X:%.6f, Y:%.6f, Z:%.6f\nMAG0, X:%.6f, Y:%.6f, Z:%.6f\n",cnt,self.motionManager.accelerometerData.acceleration.x,
//           self.motionManager.accelerometerData.acceleration.y,self.motionManager.accelerometerData.acceleration.z,self.motionManager.gyroData.rotationRate.x,
//        self.motionManager.gyroData.rotationRate.y,self.motionManager.gyroData.rotationRate.z,self.motionManager.magnetometerData.magneticField.x,
//        self.motionManager.magnetometerData.magneticField.y,self.motionManager.magnetometerData.magneticField.z];
//
//    [self.gyroLabel performSelectorOnMainThread:@selector(setText:) withObject:msg waitUntilDone:NO];
//    
//    [data appendData:[msg dataUsingEncoding:NSASCIIStringEncoding]];
//
//    NSString* name = [self.root stringByAppendingPathComponent:[NSString stringWithFormat:@"frame%u.txt",cnt]];
//    
//    [data writeToFile:name atomically:NO];
//    
////    [self.file seekToEndOfFile];
////    [self.file writeData:data];
//
//    CVPixelBufferUnlockBaseAddress(frameBuf, 0);
//    CVPixelBufferRelease(frameBuf);
//}

@end
