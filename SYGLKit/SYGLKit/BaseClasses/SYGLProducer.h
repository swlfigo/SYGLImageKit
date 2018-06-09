//
//  SYGLProducer.h
//  SYGLKit
//
//  Created by Sylar on 2018/6/3.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMedia/CoreMedia.h>
#import "SYGLConsumer.h"


@class SYGLTexture;
@protocol SYGLConsumer;

@interface SYGLProducer : NSObject
{
    dispatch_semaphore_t imageProcessingSemaphore_;
    BOOL enabled_;
    NSMutableArray *consumers_;
    CGRect outputFrame_;
    SYGLTexture *outputTexture_;
}
@property (readwrite, nonatomic, getter = isEnabled) BOOL enabled;
@property (readwrite, nonatomic) CGRect outputFrame;
@property (readonly, nonatomic) NSArray *consumers;

- (void)addConsumer:(id <SYGLConsumer>)consumer;
- (void)removeConsumer:(id <SYGLConsumer>)consumer;
- (void)removeAllConsumers;

- (void)produceAtTime:(CMTime)time;

@end
