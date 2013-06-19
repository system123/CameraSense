#import "GPUImageRadius4TextureSamplingFilter.h"

// Override vertex shader to remove dependent texture reads 
NSString *const kGPUImageRadius4TexelSamplingVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 uniform float texelWidth;
 uniform float texelHeight; 
 
 varying vec2 textureCoordinate;
 varying vec2 FASTr1;
 varying vec2 FASTr2;
// varying vec2 FASTr3;
 varying vec2 FASTr4;
 varying vec2 FASTr5;
 varying vec2 FASTr6;
// varying vec2 FASTr7;
 varying vec2 FASTr8;
 varying vec2 FASTr9;
 varying vec2 FASTr10;
// varying vec2 FASTr11;
 varying vec2 FASTr12;
 varying vec2 FASTr13;
 varying vec2 FASTr14;
// varying vec2 FASTr15;
 varying vec2 FASTr16;
 
// vec2 radius[16];
 
 void main()
 {
     gl_Position = position;
     
     vec2 scale = vec2(texelWidth, texelHeight);
     
//     radius[0] = vec2(0.0, -3.0)*scale;
//     radius[1] = vec2(1.0, -3.0)*scale;
//     radius[2] = vec2(2.0, -2.0)*scale;
//     radius[3] = vec2(3.0, -1.0)*scale;
//     radius[4] = vec2(3.0, 0.0)*scale;
//     radius[5] = vec2(3.0, 1.0)*scale;
//     radius[6] = vec2(2.0, 2.0)*scale;
//     radius[7] = vec2(1.0, 3.0)*scale;
//     radius[8] = vec2(0.0, 3.0)*scale;
//     radius[9] = vec2(-1.0, 3.0)*scale;
//     radius[10] = vec2(-2.0, 2.0)*scale;
//     radius[11] = vec2(-3.0, 1.0)*scale;
//     radius[12] = vec2(-3.0, 0.0)*scale;
//     radius[13] = vec2(-3.0, -1.0)*scale;
//     radius[14] = vec2(-2.0, -2.0)*scale;
//     radius[15] = vec2(-1.0, -3.0)*scale;
     
//     vec2 widthStep = vec2(texelWidth, 0.0);
//     vec2 heightStep = vec2(0.0, texelHeight);
//     vec2 widthHeightStep = vec2(texelWidth, texelHeight);
//     vec2 widthNegativeHeightStep = vec2(texelWidth, -texelHeight);
     
     textureCoordinate = inputTextureCoordinate.xy;
     FASTr1 = inputTextureCoordinate.xy + vec2(0.0, -3.0)*scale;
     FASTr2 = inputTextureCoordinate.xy + vec2(1.0, -3.0)*scale;
//     FASTr3 = inputTextureCoordinate.xy + radius[2];
     FASTr4 = inputTextureCoordinate.xy + vec2(3.0, -1.0)*scale;
     FASTr5 = inputTextureCoordinate.xy + vec2(3.0, 0.0)*scale;
     FASTr6 = inputTextureCoordinate.xy + vec2(3.0, 1.0)*scale;
//     FASTr7 = inputTextureCoordinate.xy + radius[6];
     FASTr8 = inputTextureCoordinate.xy + vec2(1.0, 3.0)*scale;
     FASTr9 = inputTextureCoordinate.xy + vec2(0.0, 3.0)*scale;
     FASTr10 = inputTextureCoordinate.xy + vec2(-1.0, 3.0)*scale;
//     FASTr11 = inputTextureCoordinate.xy + radius[10];
     FASTr12 = inputTextureCoordinate.xy + vec2(-3.0, 1.0)*scale;
     FASTr13 = inputTextureCoordinate.xy + vec2(-3.0, 0.0)*scale;
     FASTr14 = inputTextureCoordinate.xy + vec2(-3.0, -1.0)*scale;
//     FASTr15 = inputTextureCoordinate.xy + radius[14];
     FASTr16 = inputTextureCoordinate.xy + vec2(-1.0, -3.0)*scale;
 }
);


@implementation GPUImageRadius4TextureSamplingFilter

@synthesize texelWidth = _texelWidth; 
@synthesize texelHeight = _texelHeight; 

#pragma mark -
#pragma mark Initialization and teardown

- (id)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString;
{
    if (!(self = [super initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    
    texelWidthUniform = [filterProgram uniformIndex:@"texelWidth"];
    texelHeightUniform = [filterProgram uniformIndex:@"texelHeight"];
    
    return self;
}

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString;
{
    if (!(self = [self initWithVertexShaderFromString:kGPUImageRadius4TexelSamplingVertexShaderString fragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

- (id)initWithFragmentShaderFromFile:(NSString *)fragmentShaderFilename;
{
    NSString *fragmentShaderPathname = [[NSBundle mainBundle] pathForResource:fragmentShaderFilename ofType:@"fsh"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:fragmentShaderPathname encoding:NSUTF8StringEncoding error:nil];
    
    if (!(self = [self initWithFragmentShaderFromString:fragmentShaderString]))
    {
		return nil;
    }
    
    return self;
}

- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    if (!hasOverriddenImageSizeFactor)
    {
        _texelWidth = 1.0 / filterFrameSize.width;
        _texelHeight = 1.0 / filterFrameSize.height;
        
        runSynchronouslyOnVideoProcessingQueue(^{
            [GPUImageContext setActiveShaderProgram:filterProgram];
            if (GPUImageRotationSwapsWidthAndHeight(inputRotation))
            {
                glUniform1f(texelWidthUniform, _texelHeight);
                glUniform1f(texelHeightUniform, _texelWidth);
            }
            else
            {
                glUniform1f(texelWidthUniform, _texelWidth);
                glUniform1f(texelHeightUniform, _texelHeight);
            }
        });
    }
}

#pragma mark -
#pragma mark Accessors

- (void)setTexelWidth:(CGFloat)newValue;
{
    hasOverriddenImageSizeFactor = YES;
    _texelWidth = newValue;
    
    [self setFloat:_texelWidth forUniform:texelWidthUniform program:filterProgram];
}

- (void)setTexelHeight:(CGFloat)newValue;
{
    hasOverriddenImageSizeFactor = YES;
    _texelHeight = newValue;

    [self setFloat:_texelHeight forUniform:texelHeightUniform program:filterProgram];
}

@end
