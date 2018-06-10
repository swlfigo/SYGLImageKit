//
//  SYGLTexture.h
//  SYGLKit
//
//  Created by Sylar on 2018/5/13.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>

typedef enum SYTextureOrientation {
    SYTextureOrientationUp            = 0,
    SYTextureOrientationDown          = 1,
    SYTextureOrientationLeft          = 2,
    SYTextureOrientationRight         = 3,
    SYTextureOrientationUpMirrored    = 4,    // as above but image mirrored along other axis. horizontal flip
    SYTextureOrientationDownMirrored  = 5,    // horizontal flip
    SYTextureOrientationLeftMirrored  = 6,    // vertical flip
    SYTextureOrientationRightMirrored = 7     // vertical flip
} SYTextureOrientation;

//纹理格式
typedef struct GPUTextureOptions {
    GLenum minFilter;
    GLenum magFilter;
    GLenum wrapS;
    GLenum wrapT;
    GLenum internalFormat;
    GLenum format;
    GLenum type;
} GPUTextureOptions;

@class UIImage;
@class CALayer;
@interface SYGLTexture : NSObject

@property (readonly, nonatomic) CGSize size;
@property (readwrite, nonatomic) SYTextureOrientation orientation;
@property (readonly, nonatomic) const GLfloat *textureCoordinate;
@property (nonatomic, readwrite)GPUTextureOptions textureOptions;

+ (GLint)maximumTextureSizeForCurrentDevice;

- (id)initWithSize:(CGSize)size;
- (id)initWithCVBuffer:(CVBufferRef)CVBuffer;
- (id)initWithCGImage:(CGImageRef)image;
- (id)initWithCALayer:(CALayer *)caLayer;

- (id)initWithSize:(CGSize)size orientation:(SYTextureOrientation)orientation;
- (id)initWithCVBuffer:(CVBufferRef)CVBuffer orientation:(SYTextureOrientation)orientation;
- (id)initWithCGImage:(CGImageRef)image orientation:(SYTextureOrientation)orientation;

- (void)setupContentWithSize:(CGSize)size;
- (void)setupContentWithCVBuffer:(CVBufferRef)CVBuffer;
- (void)setupContentWithCGImage:(CGImageRef)image;
- (void)setupContentWithCALayer:(CALayer *)caLayer;

- (void)attachToCurrentFrameBufferObject;
- (void)bindToTextureIndex:(GLenum)textureIndex;

- (void)deleteTextureBuffer;

- (UIImage *)imageFromContentBuffer;


@end
