//
//  SYGLTwoInputsFilter.m
//  SYGLKit
//
//  Created by Sylar on 2018/6/10.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import "SYGLTwoInputsFilter.h"

@implementation SYGLTwoInputsFilter

- (void)dealloc
{
    [SYGLContext performSynchronouslyOnImageProcessingQueue:^{
        secondInputTexture_ = nil;
    }];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [SYGLContext performSynchronouslyOnImageProcessingQueue:^{
            [SYGLContext useImageProcessingContext];
            [filterProgram_ use];
            [filterProgram_ setTextureIndex:1 forTexture:@"secondSourceImage"];
        }];
        secondInputTexture_ = nil;
    }
    return self;
}




- (void)setInputTexture:(SYGLTexture *)texture
{
    if (!inputTexture_ ) {
        inputTexture_ = nil;
        inputTexture_ = texture;
    }
    else if (!secondInputTexture_) {
        secondInputTexture_ = nil;
        secondInputTexture_ = texture;
    }
}


- (void)renderRect:(CGRect)rect atTime:(CMTime)time
{
    if (!inputTexture_ || !secondInputTexture_ || !enabled_) {
        return;
    }
    
    if (CGSizeEqualToSize(contentSize_, CGSizeZero)) {
        self.contentSize = inputTexture_.size;
    }
    if (CGRectEqualToRect(self.outputFrame, CGRectZero)) {
        self.outputFrame = CGRectMake(0, 0, contentSize_.width, contentSize_.height);
    }
    
    if (!CGSizeEqualToSize(filterFBO_.size, contentSize_)) {
        [filterFBO_ setupStorageForOffscreenWithSize:contentSize_];
    }
    [filterFBO_ bindToPipeline];
    [filterFBO_ clearBufferWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    [inputTexture_ bindToTextureIndex:GL_TEXTURE0];
    [secondInputTexture_ bindToTextureIndex:GL_TEXTURE1];
    
    [filterProgram_ use];
    [filterProgram_ setTextureIndex:0 forTexture:@"sourceImage"];
    [filterProgram_ setTextureIndex:1 forTexture:@"secondSourceImage"];
    [self setProgramUniform];
    [filterProgram_ setCoordinatePointer:[filterFBO_ verticesCoordinateForDrawableRect:rect] coordinateSize:2 forAttribute:@"position"];
    [filterProgram_ setCoordinatePointer:inputTexture_.textureCoordinate coordinateSize:2 forAttribute:@"textureCoordinate"];
    [filterProgram_ setCoordinatePointer:secondInputTexture_.textureCoordinate coordinateSize:2 forAttribute:@"secondTextureCoordinate"];
    
    
    [filterProgram_ draw];
    
    outputTexture_ = nil;
    outputTexture_ = filterFBO_.texture;
    
    
    [self produceAtTime:time];
    
    inputTexture_ = nil;
    secondInputTexture_ = nil;
}

+ (NSString *)vertexShaderFilename
{
    static NSString *vName = @"TwoInputs";
    return vName;
}



@end
