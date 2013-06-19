//
//  GPUImageFASTCornerDetectorFilter.m
//  CameraSense
//
//  Created by Lloyd Hughes on 2013/05/21.
//  Copyright (c) 2013 Lloyd Hughes. All rights reserved.
//

#import "GPUImageGrayscaleFilter.h"
#import "GPUImageGaussianBlurFilter.h"
#import "GPUImageRadius4TextureSamplingFilter.h"
#import "GPUImageFASTCornerDetectorFilter.h"

@implementation GPUImageFASTCornerDetectorFilter

@synthesize cornersDetectedBlock;
@synthesize N = _N;
@synthesize threshold = _threshold;
@synthesize texelWidth = _texelWidth;
@synthesize texelHeight = _texelHeight;

- (id) init
{
    if (!(self = [self initWithCornerDetectionFragmentShader:@"FASTFragmentShader"])) {
        return nil;
    }
    
    return self;
}

- (id) initWithCornerDetectionFragmentShader:(NSString *)cornerDetectionFragmentShader
{
    if (!(self = [super init])) {
        return nil;
    }
    
    grayScaleFilter = [[GPUImageGrayscaleFilter alloc] init];
    [self addFilter:grayScaleFilter];
    
    medianFilter = [[GPUImageGaussianBlurFilter alloc] init];
    [medianFilter setBlurSize:1]; 
    [self addFilter:medianFilter];
  
//    __unsafe_unretained GPUImageFASTCornerDetectorFilter *weakSelf = self;
//    [grayScaleFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *filter, CMTime frameTime) {
//        [weakSelf extractCornerLocationsFromImageAtFrameTime:frameTime];
//    }];
    
    FASTCornerDetectorFilter = [[GPUImageRadius4TextureSamplingFilter alloc] initWithFragmentShaderFromFile:cornerDetectionFragmentShader];
    [self addFilter:FASTCornerDetectorFilter];
    
    [grayScaleFilter addTarget:medianFilter];
    [medianFilter addTarget:FASTCornerDetectorFilter];
    
    self.initialFilters = [NSArray arrayWithObjects:grayScaleFilter, nil];
    
    self.threshold = 30.0/255.0;
    self.N = 12.0;
    
    texelWidth = 1.0/480.0;
    texelHeight = 1.0/640.0;
  
    comboCheckUniform = [[FASTCornerDetectorFilter getFilterProgram] uniformIndex:@"ccIDX"];
    int cc[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0, 1, 2};
    glUseProgram([FASTCornerDetectorFilter getFilterProgramID]);
    glUniform1iv(comboCheckUniform, 19, cc);
    
    GPUVector2 radius[16] = { {0.0, -3.0*texelHeight},
    {1.0*texelWidth, -3.0*texelHeight},
    {2.0*texelWidth, -2.0*texelHeight},
    {3.0*texelWidth, -1.0*texelHeight},
    {3.0*texelWidth, 0.0},
     {3.0*texelWidth, 1.0*texelHeight},
    {2.0*texelWidth, 2.0*texelHeight},
    {1.0*texelWidth, 3.0*texelHeight},
     {0.0, 3.0*texelHeight},
   {-1.0*texelWidth, 3.0*texelHeight},
    {-2.0*texelWidth, 2.0*texelHeight},
    {-3.0*texelWidth, 1.0*texelHeight},
    {-3.0*texelWidth, 0.0},
   {-3.0*texelWidth, -1.0*texelHeight},
    {-2.0*texelWidth, -2.0*texelHeight},
     {-1.0*texelWidth, -3.0*texelHeight} };
    
//    [FASTCornerDetectorFilter setFloatVec2:radius[0] forUniformName:@"FASTr1"];
//    [FASTCornerDetectorFilter setFloatVec2:radius[1] forUniformName:@"FASTr2"];
    [FASTCornerDetectorFilter setFloatVec2:radius[2] forUniformName:@"FASTr3"];
//    [FASTCornerDetectorFilter setFloatVec2:radius[3] forUniformName:@"FASTr4"];
//    [FASTCornerDetectorFilter setFloatVec2:radius[4] forUniformName:@"FASTr5"];
//    [FASTCornerDetectorFilter setFloatVec2:radius[5] forUniformName:@"FASTr6"];
    [FASTCornerDetectorFilter setFloatVec2:radius[6] forUniformName:@"FASTr7"];
//    [FASTCornerDetectorFilter setFloatVec2:radius[7] forUniformName:@"FASTr8"];
//    [FASTCornerDetectorFilter setFloatVec2:radius[8] forUniformName:@"FASTr9"];
//    [FASTCornerDetectorFilter setFloatVec2:radius[9] forUniformName:@"FASTr10"];
    [FASTCornerDetectorFilter setFloatVec2:radius[10] forUniformName:@"FASTr11"];
//    [FASTCornerDetectorFilter setFloatVec2:radius[11] forUniformName:@"FASTr12"];
//    [FASTCornerDetectorFilter setFloatVec2:radius[12] forUniformName:@"FASTr13"];
//    [FASTCornerDetectorFilter setFloatVec2:radius[13] forUniformName:@"FASTr14"];
    [FASTCornerDetectorFilter setFloatVec2:radius[14] forUniformName:@"FASTr15"];
//    [FASTCornerDetectorFilter setFloatVec2:radius[15] forUniformName:@"FASTr16"];
    
    return self;
    
}

- (void)setupFilterForSize:(CGSize)filterFrameSize
{
    _texelWidth = 1.0 / filterFrameSize.width;
    _texelHeight = 1.0 / filterFrameSize.height;
//
//    [FASTCornerDetectorFilter setFloat:_texelHeight forUniformName:@"texelHeight"];
//    [FASTCornerDetectorFilter setFloat:_texelWidth forUniformName:@"texelWidth"];

    [FASTCornerDetectorFilter setupFilterForSize:filterFrameSize];
}


- (void) dealloc
{
//    free(rawImagePixels);
//    free(cornersArray);
}

- (BOOL)wantsMonochromeInput;
{
    return YES;
}

- (void)setThreshold:(CGFloat)newValue;
{
    _threshold = newValue/255.0;
    [FASTCornerDetectorFilter setFloat:newValue/255.0 forUniformName:@"threshold"];
}

- (void)setN:(CGFloat)newValue
{
    _N = newValue;
    [FASTCornerDetectorFilter setFloat:newValue forUniformName:@"N"];
}

- (void) addTarget:(id<GPUImageInput>)newTarget
{
    [FASTCornerDetectorFilter addTarget:newTarget];
}

@end

