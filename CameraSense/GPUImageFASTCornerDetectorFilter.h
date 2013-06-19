//
//  GPUImageFASTCornerDetectorFilter.h
//  CameraSense
//
//  Created by Lloyd Hughes on 2013/05/21.
//  Copyright (c) 2013 Lloyd Hughes. All rights reserved.
//

#import "GPUImageFilterGroup.h"


@class GPUImageGaussianBlurFilter;
//@class GPUImageXYDerivativeFilter;
@class GPUImageGrayscaleFilter;
@class GPUImageRadius4TextureSamplingFilter;
@class GPUImageGaussianBlurFilter;
//@class GPUImageFastBlurFilter;
//@class GPUImageThresholdedNonMaximumSuppressionFilter;
//@class GPUImageColorPackingFilter;

@interface GPUImageFASTCornerDetectorFilter : GPUImageFilterGroup
{
    GPUImageRadius4TextureSamplingFilter *FASTCornerDetectorFilter;
    GPUImageGrayscaleFilter *grayScaleFilter;
    GPUImageGaussianBlurFilter *medianFilter;
    
    GLfloat *cornersArray;
    GLubyte *rawImagePixels;
    
    CGFloat texelWidth, texelHeight;
    CGFloat threshold, N;
    
    GLint comboCheckUniform;
    GLint radiusLookupUniform;
}


// This changes the threshold value of the FAST detector default is 30
@property(readwrite, nonatomic) CGFloat threshold;

// This changes the number of adjacent pixels which need to meet the threshold criteria in order to be classified a corner
@property(readwrite, nonatomic) CGFloat N;

@property(readwrite, nonatomic) CGFloat texelWidth;
@property(readwrite, nonatomic) CGFloat texelHeight;

// This block is called on the detection of new corner points, usually on every processed frame. A C array containing normalized coordinates in X, Y pairs is passed in, along with a count of the number of corners detected and the current timestamp of the video frame
@property(nonatomic, copy) void(^cornersDetectedBlock)(GLfloat* cornerArray, NSUInteger cornersDetected, CMTime frameTime);

- (void)setupFilterForSize:(CGSize)filterFrameSize;

// Initialization and teardown
- (id)initWithCornerDetectionFragmentShader: (NSString *)cornerDetectionFragmentShader;
- (void) addTarget:(id<GPUImageInput>)newTarget;

//- (void)extractCornerLocationsFromImageAtFrameTime:(CMTime)frameTime;

@end

