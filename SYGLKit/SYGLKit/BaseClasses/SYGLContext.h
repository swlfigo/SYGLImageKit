//
//  SYGLContext.h
//  OpenGLES 01
//
//  Created by Sylar on 2017/11/21.
//  Copyright © 2017年 Sylar. All rights reserved.
//

#import <Foundation/Foundation.h>


@class EAGLContext;
@class EAGLSharegroup;
@protocol EAGLDrawable;


@interface SYGLContext : NSObject

//Context
@property(readonly, retain, nonatomic) EAGLContext *context;

//处理Queue
@property (readonly, nonatomic) dispatch_queue_t imageProcessingQueue;


//单例化Context
+ (instancetype)defaultContext;

//设置当前环境
- (void)setAsCurrentContext;
+ (void)useImageProcessingContext;

//ContextKey
+(void *)contextKey;

//imageProcessQueue
+(dispatch_queue_t)glESContextImageProcessQueue;

+ (void)performSynchronouslyOnImageProcessingQueue:(void (^)(void))block;

+ (void)performAsynchronouslyOnImageProcessingQueue:(void (^)(void))block;

//Present
- (void)presentRenderBufferToScreen;
@end
