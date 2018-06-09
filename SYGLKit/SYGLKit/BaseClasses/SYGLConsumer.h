//
//  SYGLConsumer.h
//  SYGLKit
//
//  Created by Sylar on 2018/6/3.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreMedia/CoreMedia.h>

@class UIImage;
@class SYGLTexture;

enum SYGLConsumerContentMode {
    SYGLConsumerContentModeNormal,
    SYGLConsumerContentModeResizeToFill,     //The option to scale the content to fit the size of itself by changing the aspect ratio of the content if necessary.
    SYGLConsumerContentModeResizeAspect,     //The option to scale the content to fit the size of the view by maintaining the aspect ratio. Any remaining area of the view’s bounds is transparent.
    SYGLConsumerContentModeResizeAspectFill  //The option to scale the content to fill the size of the view. Some portion of the content may be clipped to fill the view’s bounds.
};
typedef enum SYGLConsumerContentMode SYGLConsumerContentMode;

@protocol SYGLConsumer <NSObject>

@property (readwrite, nonatomic, getter=isEnabled) BOOL enabled;
@property (readwrite, nonatomic) CGSize contentSize;
@property (readwrite, nonatomic) SYGLConsumerContentMode contentMode;


- (void)setInputTexture:(SYGLTexture *)inputTexture;
- (void)renderRect:(CGRect)rect atTime:(CMTime)time;

@optional
- (UIImage *)imageFromCurrentFrame;

@end
