//
//  SYGLProducer.m
//  SYGLKit
//
//  Created by Sylar on 2018/6/3.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import "SYGLProducer.h"
#import "SYGLContext.h"
#import "SYGLTexture.h"
#import "SYGLConsumer.h"
@implementation SYGLProducer

@synthesize enabled = enabled_;
@synthesize outputFrame = outputFrame_;
@synthesize consumers = consumers_;

- (instancetype)init
{
    self = [super init];
    if (self) {
        imageProcessingSemaphore_ = dispatch_semaphore_create(1);
        enabled_ = YES;
        self.outputFrame = CGRectZero;
        consumers_ = [[NSMutableArray alloc] init];
        outputTexture_ = nil;
    }
    return self;
}


#pragma mark - Consumers Manager

- (void)addConsumer:(id <SYGLConsumer>)consumer
{
    [SYGLContext performSynchronouslyOnImageProcessingQueue:^{
        
        if (!consumer) {
            return;
        }
        
        [consumers_ addObject:consumer];
    }];
    
}



- (void)removeConsumer:(id <SYGLConsumer>)consumer
{
    [SYGLContext performSynchronouslyOnImageProcessingQueue:^{
        
        if ([consumers_ containsObject:consumer]) {
            
            [consumers_ removeObject:consumer];
        }
    }];

}

- (void)removeAllConsumers
{
    [SYGLContext performSynchronouslyOnImageProcessingQueue:^{
        
        [consumers_ removeAllObjects];
        
    }];

}

- (void)produceAtTime:(CMTime)time
{
    if (!self.isEnabled) {
        return;
    }
    
    if (outputTexture_ && [consumers_ count]) {
        for (id <SYGLConsumer> consumer in consumers_) {
            [SYGLContext performSynchronouslyOnImageProcessingQueue:^{
                [consumer setInputTexture:outputTexture_];
                [consumer renderRect:self.outputFrame atTime:time];
            }];
        }
    }
}
@end
