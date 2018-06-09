//
//  SYGLFrameBuffer.h
//  SYGLKit
//
//  Created by Sylar on 2018/5/13.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SYGLTexture.h"

typedef enum SYGLFrameBufferObjectType {
    SYGLFrameBufferObjectTypeUnknow            = 0,
    SYGLFrameBufferObjectTypeOffscreen         = 1,
    SYGLFrameBufferObjectTypeForDisplay        = 2,
    SYGLFrameBufferObjectTypeSpecifiedCVBuffer = 3
} SYGLFrameBufferObjectType;

enum SYGLFrameBufferObjectContentMode {
    SYGLFrameBufferObjectContentModeNormal,
    SYGLFrameBufferObjectContentModeResizeToFill,     //The option to scale the content to fit the size of itself by changing the aspect ratio of the content if necessary.
    SYGLFrameBufferObjectContentModeResizeAspect,     //The option to scale the content to fit the size of the view by maintaining the aspect ratio. Any remaining area of the view’s bounds is transparent.
    SYGLFrameBufferObjectContentModeResizeAspectFill  //The option to scale the content to fill the size of the view. Some portion of the content may be clipped to fill the view’s bounds.
};
typedef enum SYGLFrameBufferObjectContentMode SYGLFrameBufferObjectContentMode;


@class CAEAGLLayer;
@interface SYGLFrameBuffer : NSObject

@property(readonly) CGSize size;
@property (readonly, nonatomic) SYGLTexture *texture;
@property (nonatomic) SYGLFrameBufferObjectContentMode contentMode;

- (id)init;

//绑定FBO方式
- (void)setupStorageForOffscreenWithSize:(CGSize)fboSize;
- (void)setupStorageForDisplayFromLayer:(CAEAGLLayer *)layer;
- (void)setupStorageWithSpecifiedCVBuffer:(CVBufferRef)CVBuffer;

//当前Producer绑定FBO
- (void)bindToPipeline;
- (void)clearBufferWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;

//清空FBO
-(void)deleteFrameBufferObject;

//计算相对的定点坐标
- (const GLfloat *)verticesCoordinateForDrawableRect:(CGRect)rect;
@end
