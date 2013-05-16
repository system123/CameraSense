//
//  ViewController.m
//  CameraSense
//
//  Created by Lloyd Hughes on 2013/03/28.
//  Copyright (c) 2013 Lloyd Hughes. All rights reserved.
//

#import "ViewController.h"
#import "CMMotionManagerSim.h"

int cnt;

@interface ViewController ()
@property (strong, nonatomic) CMMotionManager  *motionManager;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (nonatomic, retain) AVCaptureSession *session;
@property (nonatomic, retain) AVCaptureDevice *camera;
@property (nonatomic, retain) AVCaptureDeviceInput *cameraStream;
@property (nonatomic, retain) AVCaptureVideoDataOutput *outputStream;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *videoLayer;
@property (nonatomic, retain) NSMutableArray *bufferArray;
@property (nonatomic, strong) NSString *root;
@property (nonatomic) BOOL firstWrite;
@property (strong, retain) NSFileHandle *file;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    cnt = 0;
    NSArray *dirPaths;
    NSString *docsDir;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                   NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
//    self.root = [docsDir stringByAppendingPathComponent:@"sensors.txt"];
    self.root = docsDir;
    
    NSFileManager* filemgr = [NSFileManager defaultManager];
    
    NSMutableData* data = [NSMutableData alloc];
    
    NSString *header = [NSString stringWithFormat:@"\nwidth: %u, height: %u, bytesPerRow: %u \n",100,10,24];
    [data appendData:[header dataUsingEncoding:NSASCIIStringEncoding]];
    
    [filemgr createFileAtPath:self.root contents:data attributes:nil];
    
    if ([filemgr isWritableFileAtPath:self.root]  == YES)
        NSLog (@"File is writable");
    else
        NSLog (@"File is read only");

    
    self.file = [NSFileHandle fileHandleForWritingAtPath:self.root];
    
    if (self.file == nil)
        NSLog(@"Failed to open file");

    [self.file writeData:data];

    self.motionManager = [[CMMotionManager alloc] init];
    self.queue = [[NSOperationQueue alloc] init];
    
    [self.accelLabel setText:self.root];
    
    if (self.motionManager.accelerometerAvailable){
        
        self.motionManager.accelerometerUpdateInterval = 1.0/60.0;
        [self.motionManager startAccelerometerUpdates];
//        [self.motionManager startAccelerometerUpdatesToQueue:self.queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
//            
//            NSString* msg;
//            
//            if (error){
//                [self.motionManager stopAccelerometerUpdates];
//                msg = [NSString stringWithFormat:@"Accelerometer encounted an error: %@",error];
//            } else {
//                msg = [NSString stringWithFormat:@"X:%.3f\nY:%.3f\nZ:%.3f",accelerometerData.acceleration.x,accelerometerData.acceleration.y,accelerometerData.acceleration.z];
//            }
//            
//            [self.accelLabel performSelectorOnMainThread:@selector(setText:) withObject:msg waitUntilDone:NO];
//            
//            
//        }];
    } else {
        [self.accelLabel setText:@"This device does not have an accelerometer"];
    }
    
    if (self.motionManager.gyroAvailable){
        
        self.motionManager.gyroUpdateInterval = 1.0/60.0;
        [self.motionManager startGyroUpdates];
//        [self.motionManager startGyroUpdatesToQueue:self.queue withHandler:^(CMGyroData *gyroData, NSError *error) {
//            NSString* msg;
//            
//            if (error){
//                [self.motionManager stopGyroUpdates];
//                msg = [NSString stringWithFormat:@"Gyro encounted an error: %@",error];
//            } else {
//                msg = [NSString stringWithFormat:@"X:%.3f\nY:%.3f\nZ:%.3f",gyroData.rotationRate.x,gyroData.rotationRate.y,gyroData.rotationRate.z];
//            }
//            
//            [self.gyroLabel performSelectorOnMainThread:@selector(setText:) withObject:msg waitUntilDone:NO];
//            
//        }];
    } else {
        [self.accelLabel setText:@"This device does not have an gyroscope"];
    }
    
    if (self.motionManager.magnetometerAvailable){
        
        self.motionManager.magnetometerUpdateInterval = 1.0/60.0;
        [self.motionManager startMagnetometerUpdates];
//        [self.motionManager startMagnetometerUpdatesToQueue:self.queue withHandler:^(CMMagnetometerData *magnetometerData, NSError *error) {
//            
//            NSString* msg;
//            
//            if (error){
//                [self.motionManager stopAccelerometerUpdates];
//                msg = [NSString stringWithFormat:@"Magnemometer encounted an error: %@",error];
//            } else {
//                msg = [NSString stringWithFormat:@"X:%.3f\nY:%.3f\nZ:%.3f", magnetometerData.magneticField.x, magnetometerData.magneticField.y, magnetometerData.magneticField.z];
//            }
//            
//            [self.magLabel performSelectorOnMainThread:@selector(setText:) withObject:msg waitUntilDone:NO];
//                        
//        }];
    } else {
        [self.magLabel setText:@"This device does not have an magnemometer"];
    }
    
    self.session = [[AVCaptureSession alloc] init];
       
    self.session.sessionPreset = AVCaptureSessionPreset640x480;
    
    self.camera = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
    
    NSError *error = [NSError alloc];
    self.cameraStream = [AVCaptureDeviceInput deviceInputWithDevice:self.camera error:&error];
    
    if ([self.session canAddInput:self.cameraStream])
        [self.session addInput:self.cameraStream];
    
    self.videoLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    
    [self.videoLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    CALayer *rootLayer = [[self view] layer];
    [rootLayer setMasksToBounds:YES];
    [self.videoLayer setFrame:CGRectMake(0, 0, 480, 640)];
    [rootLayer insertSublayer:self.videoLayer atIndex:0];
    
    self.outputStream = [[AVCaptureVideoDataOutput alloc]init];
    self.outputStream.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_24BGR]
                                                                  forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
    [self.outputStream setAlwaysDiscardsLateVideoFrames:YES];
    
    if ([self.session canAddOutput:self.outputStream ])
        [self.session addOutput:self.outputStream];
    
    dispatch_queue_t queue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL);
    [self.outputStream setSampleBufferDelegate:self queue:queue];
    
    [self.session startRunning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeGreeting:(id)sender {
    [self.session stopRunning];
    [self.file closeFile];
   }

- (BOOL)textFieldShouldReturn:(UITextField*)theTextField {
    /*if (theTextField == self.textField){
        [theTextField resignFirstResponder];
    }*/
    
    return YES;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef frameBuf = CMSampleBufferGetImageBuffer(sampleBuffer);
        
    CVPixelBufferLockBaseAddress(frameBuf, 0);
    
    frameBuf = CVPixelBufferRetain(frameBuf);
    
    size_t width = CVPixelBufferGetWidthOfPlane(frameBuf,0);
    size_t height = CVPixelBufferGetHeightOfPlane(frameBuf,0);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(frameBuf,0);
    
    uint8_t *grayBuf = CVPixelBufferGetBaseAddressOfPlane(frameBuf, 0);
    
    NSData *tmp = [[NSData alloc] initWithBytes:grayBuf length:height*bytesPerRow];

    NSMutableData *data = [NSMutableData alloc];
    
    NSString* msg;
    
    cnt++;

    msg = [NSString stringWithFormat:@"\nFRAME %u\nACC0, X:%.6f, Y:%.6f, Z:%.6f\nGYR0, X:%.6f, Y:%.6f, Z:%.6f\nMAG0, X:%.6f, Y:%.6f, Z:%.6f\n",cnt,self.motionManager.accelerometerData.acceleration.x,
           self.motionManager.accelerometerData.acceleration.y,self.motionManager.accelerometerData.acceleration.z,self.motionManager.gyroData.rotationRate.x,
        self.motionManager.gyroData.rotationRate.y,self.motionManager.gyroData.rotationRate.z,self.motionManager.magnetometerData.magneticField.x,
        self.motionManager.magnetometerData.magneticField.y,self.motionManager.magnetometerData.magneticField.z];

    [self.gyroLabel performSelectorOnMainThread:@selector(setText:) withObject:msg waitUntilDone:NO];
    
    [data appendData:[msg dataUsingEncoding:NSASCIIStringEncoding]];

    NSString* name = [self.root stringByAppendingPathComponent:[NSString stringWithFormat:@"frame%u.txt",cnt]];
    
    [data writeToFile:name atomically:NO];
    
//    [self.file seekToEndOfFile];
//    [self.file writeData:data];

    CVPixelBufferUnlockBaseAddress(frameBuf, 0);
    CVPixelBufferRelease(frameBuf);
}

@end
