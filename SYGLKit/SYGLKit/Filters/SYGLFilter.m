//
//  SYGLFilter.m
//  SYGLKit
//
//  Created by Sylar on 2018/6/4.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import "SYGLFilter.h"

@interface SYGLFilter()

@end

@implementation SYGLFilter

@synthesize contentSize = contentSize_;
@synthesize contentMode;

-(void)dealloc{
    [SYGLContext performSynchronouslyOnImageProcessingQueue:^{
        outputTexture_ = nil;
    }];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        producers_ = [[NSMutableArray alloc]init];
        contentSize_ = CGSizeZero;
        [SYGLContext performSynchronouslyOnImageProcessingQueue:^{
            [SYGLContext useImageProcessingContext];
            filterFBO_ = [[SYGLFrameBuffer alloc]init];
            filterProgram_ = [[SYGLProgram alloc] initWithVertexShaderFilename:[[self class] vertexShaderFilename] fragmentShaderFilename:[[self class] fragmentShaderFilename]];
            [filterProgram_ use];
            
            // This does assume a name of "sourceImage" input texture in the fragment shader
            [filterProgram_ setTextureIndex:0 forTexture:@"sourceImage"];
            
            inputTexture_ = nil;
        }];
    }
    return self;
}

- (id)initWithContentSize:(CGSize)contentSize{
    self = [self init];
    if (self) {
        self.contentSize = contentSize;
    }
    return self;
}


- (void)setInputTexture:(SYGLTexture *)texture
{
    if (inputTexture_ != texture) {
        inputTexture_ = nil;
        inputTexture_ = texture;
    }
}

-(UIImage *)imageFromCurrentFrame{
    if ([consumers_ count]) {
        id <SYGLConsumer> consumer = [consumers_ lastObject];
        if ([consumer respondsToSelector:@selector(imageFromCurrentFrame)]) {
            return [consumer imageFromCurrentFrame];
        }
    }
    return [outputTexture_ imageFromContentBuffer];
}

- (void)renderRect:(CGRect)rect atTime:(CMTime)time
{
    if (!inputTexture_ || !self.isEnabled) {
        return;
    }
    
    if (CGSizeEqualToSize(self.contentSize, CGSizeZero)) {
        self.contentSize = inputTexture_.size;
    }
    if (CGRectEqualToRect(self.outputFrame, CGRectZero)) {
        self.outputFrame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    }
    
    if (!CGSizeEqualToSize(filterFBO_.size, contentSize_)) {
        [filterFBO_ setupStorageForOffscreenWithSize:contentSize_];
    }
    //绑定当前滤镜FBO
    [filterFBO_ bindToPipeline];
    [filterFBO_ clearBufferWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    //激活GL_TEXTURE0 位置的纹理
    [inputTexture_ bindToTextureIndex:GL_TEXTURE0];
    
    [filterProgram_ use];
    
    //子类可重写此方法修改FSH与VSH数值
    [self setProgramUniform];
    
    // This does assume a name of "position" in the vertext shader
    [filterProgram_ setCoordinatePointer:[filterFBO_ verticesCoordinateForDrawableRect:rect] coordinateSize:2 forAttribute:@"position"];
    
    // This does assume a name of "textureCoordinate" in the vertext shader
    [filterProgram_ setCoordinatePointer:inputTexture_.textureCoordinate coordinateSize:2 forAttribute:@"textureCoordinate"];
    
    [filterProgram_ draw];

    outputTexture_ = filterFBO_.texture;

    
    [self produceAtTime:time];
}

#pragma mark - The Methods Be Overrided In Subclass If Need
//子类滤镜重写 FSH VSH
+ (NSString *)vertexShaderFilename
{
    static NSString *vName = @"Default";
    return vName;
}

+ (NSString *)fragmentShaderFilename
{
    static NSString *fName = @"Default";
    return fName;
}

- (void)setProgramUniform
{
    
}


@end
