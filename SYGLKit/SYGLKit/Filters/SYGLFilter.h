//
//  SYGLFilter.h
//  SYGLKit
//
//  Created by Sylar on 2018/6/4.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import "SYGLProducer.h"
#import "SYGLConsumer.h"
#import "SYGLContext.h"
#import "SYGLFrameBuffer.h"
#import "SYGLProgram.h"
#import "SYGLTexture.h"

@interface SYGLFilter : SYGLProducer <SYGLConsumer>
{
    NSMutableArray *producers_;
    SYGLFrameBuffer *filterFBO_;
    SYGLProgram *filterProgram_;
    SYGLTexture *inputTexture_;
    CGSize contentSize_;
}

+ (NSString *)vertexShaderFilename;
+ (NSString *)fragmentShaderFilename;

- (id)initWithContentSize:(CGSize)contentSize;

- (void)setProgramUniform;

- (UIImage *)imageFromCurrentFrame;
@end
