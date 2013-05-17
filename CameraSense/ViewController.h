//
//  ViewController.h
//  CameraSense
//
//  Created by Lloyd Hughes on 2013/03/28.
//  Copyright (c) 2013 Lloyd Hughes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import "GPUImage.h"

#define BALL_R 25

struct motionData {
    size_t width;
    size_t height;
    size_t bytesPerRow;
    uint8_t* video;    
    double gyroX, gyroY, gyroZ;
    double accelX, accelY, accelZ;
    double magX, magY, magZ;
};

@interface ViewController : UIViewController <UITextFieldDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, GPUImageMovieWriterDelegate>

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

- (IBAction)stopCapture:(id)sender;
- (IBAction)startCapture:(id)sender;

- (void) writeSampleBuffer:(CMSampleBufferRef)sampleBuffer withSensorData:(NSData *)sensorData frameNumber:(int) fno;

- (void) frameAboutToWrite:(CMTime)frameTime;

@property (weak, nonatomic) IBOutlet UILabel *magLabel;
@property (weak, nonatomic) IBOutlet UILabel *accelLabel;
@property (weak, nonatomic) IBOutlet UILabel *gyroLabel;
@property (weak, nonatomic) IBOutlet UIButton *button;

@end
