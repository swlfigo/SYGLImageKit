//
//  SYGLView.m
//  SYGLKit
//
//  Created by Sylar on 2018/6/7.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import "SYGLView.h"
#import "SYGLContext.h"
#import "SYGLFrameBuffer.h"
#import "SYGLTexture.h"
#import "SYGLProgram.h"


@interface SYGLView()
{
    BOOL superClassInitHasCompleted_;
}
@end

@implementation SYGLView

@synthesize enabled = enabled_;
@synthesize contentSize = contentSize_;
@synthesize contentMode = contentMode_;

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self performCommonStepsForInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self performCommonStepsForInit];
        
        self.contentSize = displayFBO_.size;
    }
    return self;
}


- (void)performCommonStepsForInit
{
    enabled_ = YES;
    contentSize_ = CGSizeZero;
    contentMode_ = SYGLConsumerContentModeNormal;
    superClassInitHasCompleted_ = YES;
    displayFBO_ = nil;
    self.opaque = YES;
    
    
    if ([super respondsToSelector:@selector(setContentScaleFactor:)])
    {
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
    }
    else {
        [self setupDisplayFBO];
    }
    
    
    [SYGLContext performSynchronouslyOnImageProcessingQueue:^{
        [SYGLContext useImageProcessingContext];
        
        inputTexture_ = nil;
        
        displayProgram_ = [[SYGLProgram alloc] initWithVertexShaderFilename:@"Default" fragmentShaderFilename:@"Default"];
        
        [displayProgram_ setTextureIndex:0 forTexture:@"sourceImage"];
    }];
    
}

#pragma mark - FBO
- (void)setContentScaleFactor:(CGFloat)contentScaleFactor
{
    [super setContentScaleFactor:contentScaleFactor];
    
    // UIView初始化时会调用此set函数同时造成内存泄漏，原因不明，故加此判断。
    if (superClassInitHasCompleted_) {
        [self setupDisplayFBO];
    }
}


- (void)setupDisplayFBO
{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    
    
    [SYGLContext performSynchronouslyOnImageProcessingQueue:^{
        if (displayFBO_) {
            [displayFBO_ deleteFrameBufferObject];
            displayFBO_ = nil;
        }
        displayFBO_ = [[SYGLFrameBuffer alloc] init];
        [displayFBO_ setupStorageForDisplayFromLayer:eaglLayer];
    }];
}

- (void)setInputTexture:(SYGLTexture *)texture
{
    if (inputTexture_ != texture) {

        inputTexture_ = texture;

    }
}


- (void)renderRect:(CGRect)rect atTime:(CMTime)time
{
    if (!inputTexture_ || !self.isEnabled) {
        return;
    }
    [[SYGLContext defaultContext] setAsCurrentContext];
    [displayFBO_ setContentMode:(SYGLFrameBufferObjectContentMode)self.contentMode];
    [displayFBO_ bindToPipeline];
    [displayFBO_ clearBufferWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    [inputTexture_ bindToTextureIndex:GL_TEXTURE0];
    [displayProgram_ use];
    [displayProgram_ setCoordinatePointer:[displayFBO_ verticesCoordinateForDrawableRect:rect] coordinateSize:2 forAttribute:@"position"];
    [displayProgram_ setCoordinatePointer:inputTexture_.textureCoordinate coordinateSize:2 forAttribute:@"textureCoordinate"];
    [displayProgram_ draw];
    [[SYGLContext defaultContext]presentRenderBufferToScreen];
}

@end
