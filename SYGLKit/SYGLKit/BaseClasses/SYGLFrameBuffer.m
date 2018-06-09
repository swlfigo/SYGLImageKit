//
//  SYGLFrameBuffer.m
//  SYGLKit
//
//  Created by Sylar on 2018/5/13.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import "SYGLFrameBuffer.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <AVFoundation/AVFoundation.h>
#import "SYGLTexture.h"

@interface SYGLFrameBuffer()
{
    GLuint frameBuffer_;
    GLuint renderBuffer_;
    SYGLTexture *texture_;
    CGSize size_;
    SYGLFrameBufferObjectType type;
    CAEAGLLayer *eaglLayer_;
    CVBufferRef specifiedCVBuffer_;
}
@end


@implementation SYGLFrameBuffer

@synthesize size = size_;
@synthesize texture = texture_;
@synthesize contentMode = contentMode_;

- (void)dealloc
{
    [self deleteFrameBufferObject];
}

- (void)deleteFrameBufferObject
{
    if (texture_) {
        texture_ = nil;;
    }
    if (renderBuffer_) {
        glDeleteRenderbuffers(1, &renderBuffer_);
    }
    if (frameBuffer_) {
        glDeleteFramebuffers(1, &frameBuffer_);
    }
    frameBuffer_ = 0;
    renderBuffer_ = 0;
    texture_ = nil;
    size_ = CGSizeZero;
    type = SYGLFrameBufferObjectTypeUnknow;
    eaglLayer_ = nil;
    specifiedCVBuffer_ = NULL;
}

- (id)init
{
    self = [super init];
    if (self) {
        frameBuffer_ = 0;
        renderBuffer_ = 0;
        texture_ = nil;
        size_ = CGSizeZero;
        contentMode_ = SYGLFrameBufferObjectContentModeNormal;
        type = SYGLFrameBufferObjectTypeUnknow;
        eaglLayer_ = nil;
        specifiedCVBuffer_ = NULL;
    }
    return self;
}

//离屏FBO
- (void)setupStorageForOffscreenWithSize:(CGSize)size
{
    if ((type != SYGLFrameBufferObjectTypeOffscreen && type != SYGLFrameBufferObjectTypeUnknow) || !CGSizeEqualToSize(size_, size)) {
        [self deleteFrameBufferObject];
    }
    size_ = size;
    type = SYGLFrameBufferObjectTypeOffscreen;
}

//显示FBO
- (void)setupStorageForDisplayFromLayer:(CAEAGLLayer *)layer
{
    CGSize layerSize = CGSizeMake(layer.frame.size.width * layer.contentsScale, layer.frame.size.height * layer.contentsScale);
    if ((type != SYGLFrameBufferObjectTypeForDisplay && type != SYGLFrameBufferObjectTypeUnknow) || eaglLayer_ != layer || !CGSizeEqualToSize(size_, layerSize)) {
        [self deleteFrameBufferObject];
    }
    eaglLayer_ = layer;
    size_ = CGSizeMake(eaglLayer_.frame.size.width * eaglLayer_.contentsScale, eaglLayer_.frame.size.height * eaglLayer_.contentsScale);
    type = SYGLFrameBufferObjectTypeForDisplay;
}

//CVBuffer-与离屏FBO差不多
- (void)setupStorageWithSpecifiedCVBuffer:(CVBufferRef)CVBuffer
{
    if ((type != SYGLFrameBufferObjectTypeSpecifiedCVBuffer && type != SYGLFrameBufferObjectTypeUnknow) || specifiedCVBuffer_  != CVBuffer ) {
        [self deleteFrameBufferObject];
    }
    specifiedCVBuffer_ = CVBuffer;
    size_ = CGSizeMake(CVPixelBufferGetWidth(specifiedCVBuffer_), CVPixelBufferGetHeight(specifiedCVBuffer_));
    type = SYGLFrameBufferObjectTypeSpecifiedCVBuffer;
}


#pragma  mark - FBO Manager
//和FBO绑定RenderBuffer或者纹理
- (void)generateFrameBufferObject
{
    glGenFramebuffers(1, &frameBuffer_);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer_);
    if (type == SYGLFrameBufferObjectTypeOffscreen) {
        texture_ = [[SYGLTexture alloc] initWithSize:size_];
        [texture_ bindToTextureIndex:GL_TEXTURE0];
        [texture_ attachToCurrentFrameBufferObject];
    }
    else if (type == SYGLFrameBufferObjectTypeForDisplay) {
        glGenRenderbuffers(1, &renderBuffer_);
        glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer_);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer_);
        
        if ([EAGLContext currentContext]) {
            [[EAGLContext currentContext] renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer_];
        }
    }
    else if (type == SYGLFrameBufferObjectTypeSpecifiedCVBuffer) {
        texture_ = [[SYGLTexture alloc] initWithCVBuffer:specifiedCVBuffer_];
        [texture_ bindToTextureIndex:GL_TEXTURE0];
        [texture_ attachToCurrentFrameBufferObject];
    }
}

- (void)bindToPipeline
{
    if (!frameBuffer_) {
        [self generateFrameBufferObject];
    }
    
    if (renderBuffer_) {
        glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer_);
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer_);
    
    glViewport(0, 0, size_.width, size_.height);
}



- (void)clearBufferWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha
{
    [self bindToPipeline];
    glClearColor(red, green, blue, alpha);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

//计算 Contentsize 与 Outputframe 得出的相对定点坐标
//ContentSize指这级滤镜画布大小
//OutputFrame指上一级滤镜传进来纹理,希望的大小以及顶点开始位置
//默认情况,这个计算将上一级纹理，在这一级画布上居中绘制，超出部分裁剪掉
- (const GLfloat *)verticesCoordinateForDrawableRect:(CGRect)rect
{
    static CGRect preRect = {0.0, 0.0, 0.0, 0.0};
    static GLfloat vCoordinate[8] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
    
    CGRect adjustedRect = [self adjustCGRect:rect withContentMode:self.contentMode];
    
    if (!CGRectEqualToRect(preRect, adjustedRect)) {
        GLfloat left   = adjustedRect.origin.x / size_.width * 2.0 - 1.0;
        GLfloat right  = (adjustedRect.origin.x + adjustedRect.size.width) / size_.width * 2.0 - 1.0;
        GLfloat top    = (1.0 - adjustedRect.origin.y / size_.height) * 2.0 - 1.0;
        GLfloat bottom = (1.0 - (adjustedRect.origin.y + adjustedRect.size.height) / size_.height) * 2.0 - 1.0;
        
        vCoordinate[0] = left;
        vCoordinate[1] = bottom;
        vCoordinate[2] = right;
        vCoordinate[3] = bottom;
        vCoordinate[4] = left;
        vCoordinate[5] = top;
        vCoordinate[6] = right;
        vCoordinate[7] = top;
    }
    
    return vCoordinate;
}

- (CGRect)adjustCGRect:(CGRect)rect withContentMode:(SYGLFrameBufferObjectContentMode)contentMode
{
    CGRect adjustedRect;
    
    switch (contentMode) {
        case SYGLFrameBufferObjectContentModeResizeToFill:
            adjustedRect = CGRectMake(0, 0, self.size.width, self.size.height);
            break;
        case SYGLFrameBufferObjectContentModeResizeAspect:
            adjustedRect = AVMakeRectWithAspectRatioInsideRect(rect.size, CGRectMake(0, 0, size_.width, size_.height));
            break;
        case SYGLFrameBufferObjectContentModeResizeAspectFill:
            adjustedRect = rect;
            break;
        default:
            adjustedRect = rect;
            break;
    }
    
    return adjustedRect;
}

@end
