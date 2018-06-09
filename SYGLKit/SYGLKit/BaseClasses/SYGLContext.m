//
//  SYGLContext.m
//  OpenGLES 01
//
//  Created by Sylar on 2017/11/21.
//  Copyright © 2017年 Sylar. All rights reserved.
//

#import "SYGLContext.h"
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/EAGLDrawable.h>

@interface SYGLContext(){
    EAGLSharegroup *sharegroup_;
    EAGLContext *context_;
}
@end

@implementation SYGLContext
@synthesize context = _context;

static void *glESContextQueueKey;

+(void *)contextKey{
    return glESContextQueueKey;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        glESContextQueueKey = &glESContextQueueKey;
        //创建GL队列
        _imageProcessingQueue = dispatch_queue_create("SY.glESImageProcessQueue", NULL);
        //绑定Key与队列
        dispatch_queue_set_specific(_imageProcessingQueue, glESContextQueueKey, (__bridge void *)self, NULL);
    }
    return self;
}

-(EAGLContext *)context{
    if (_context == nil) {
        _context = [self createContext];
        [EAGLContext setCurrentContext:_context];
        
        // Set up a few global settings for the image processing pipeline
        glDisable(GL_DEPTH_TEST);
    }
    return _context;
}

- (EAGLContext *)createContext{
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    NSAssert(context != nil, @"Unable to create an OpenGL ES 2.0 context. The GPUImage framework requires OpenGL ES 2.0 support to work.");
    return context;
}

+(instancetype)defaultContext{
    static dispatch_once_t pred;
    static SYGLContext *sharedImageProcessingContext;
    dispatch_once(&pred, ^{
        sharedImageProcessingContext = [[[self class]alloc]init];
    });
    return sharedImageProcessingContext;
}

#pragma mark - Set As Current Context
- (void)setAsCurrentContext
{
    EAGLContext *imageProcessingContext = [self context];
    if ([EAGLContext currentContext] != imageProcessingContext)
    {
        [EAGLContext setCurrentContext:imageProcessingContext];
    }
}

+(void)useImageProcessingContext{
    [[SYGLContext defaultContext]setAsCurrentContext];
}

+(dispatch_queue_t)glESContextImageProcessQueue{
    return [[self defaultContext] imageProcessingQueue];
}


+(void)performSynchronouslyOnImageProcessingQueue:(void (^)(void))block{
    dispatch_queue_t imageProcessingQueue = [self glESContextImageProcessQueue];
    
    if (block) {
        if (dispatch_get_specific([self contextKey])) {
            block();
        }else{
            dispatch_sync(imageProcessingQueue, block);
        }
    }
    
}

+(void)performAsynchronouslyOnImageProcessingQueue:(void (^)(void))block{
    
    dispatch_queue_t imageProcessingQueue = [self glESContextImageProcessQueue];
    
    if (block) {
        if (dispatch_get_specific([self contextKey])) {
            block();
        }else{
            dispatch_async(imageProcessingQueue, block);
        }
    }
}


#pragma mark - Render
-(void)presentRenderBufferToScreen{
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
