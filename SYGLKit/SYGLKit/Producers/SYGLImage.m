//
//  SYGLImage.m
//  SYGLKit
//
//  Created by Sylar on 2018/6/8.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import "SYGLImage.h"
#import <UIKit/UIKit.h>
#import "SYGLTexture.h"
#import "SYGLConsumer.h"
#import "SYGLContext.h"
@interface SYGLImage()
{
    UIImage *sourceImage_;
    UIImage *processedImage_;
}
@end

@implementation SYGLImage

@synthesize sourceImage = sourceImage_;



-(instancetype)initWithUIImage:(UIImage *)image{
    if (self = [super init]) {
        sourceImage_ = nil;
        processedImage_ = nil;
        self.sourceImage = image;
        outputFrame_ = CGRectMake(0, 0, outputTexture_.size.width, outputTexture_.size.height);
        _size = CGSizeMake(outputTexture_.size.width, outputTexture_.size.height);
        
    }
    return self;
}


#pragma mark - Properties' Setters & Getters

- (void)setSourceImage:(UIImage *)sourceImage
{
    if (sourceImage_ != sourceImage) {
        [outputTexture_ deleteTextureBuffer];
        sourceImage_ = sourceImage;
        if (processedImage_) {
            processedImage_ = nil;
        }
    
        [self initOutputTexture];
    }
}

- (UIImage *)processedImage
{
    if (!self.isEnabled || [consumers_ count] == 0 || !sourceImage_) {
        return nil;
    }
    
    if (!processedImage_) {
        
        [SYGLContext performSynchronouslyOnImageProcessingQueue:^{
            [self produceAtTime:kCMTimeInvalid];
            id <SYGLConsumer> consumer = [consumers_ objectAtIndex:0];
            if ([consumer respondsToSelector:@selector(imageFromCurrentFrame)]) {
                processedImage_ = [consumer imageFromCurrentFrame];
            }
        }];
    };
    
    return processedImage_;
}

- (void)initOutputTexture
{
    if (sourceImage_) {
       
        [SYGLContext performSynchronouslyOnImageProcessingQueue:^{
            if (outputTexture_) {
                outputTexture_ = nil;
            }
            
            outputTexture_ = [[SYGLTexture alloc] initWithCGImage:sourceImage_.CGImage];
            outputTexture_.orientation = [self textureOrientationByImageOrientation:sourceImage_.imageOrientation];
        }];
    }
    else {
        
        [SYGLContext performSynchronouslyOnImageProcessingQueue:^{
            if (outputTexture_) {
                outputTexture_ = nil;
            }
        }];
    }
}


- (SYTextureOrientation)textureOrientationByImageOrientation:(UIImageOrientation)imageOrientation
{
    SYTextureOrientation textureOrientation = SYTextureOrientationUp;
    switch (imageOrientation) {
        case UIImageOrientationUp:
            textureOrientation = SYTextureOrientationDown;
            break;
            
        default:
            break;
    }
    return textureOrientation;
}

#pragma mark - Consumers Manager

- (void)addConsumer:(id <SYGLConsumer>)consumer
{
    if (processedImage_) {
        processedImage_ = nil;
    }
    
    [super addConsumer:consumer];
}


- (void)removeConsumer:(id<SYGLConsumer>)consumer
{
    if (processedImage_) {
        processedImage_ = nil;
    }
    
    [super removeConsumer:consumer];
}

- (void)removeAllConsumers
{
    if (processedImage_) {
        processedImage_ = nil;
    }
    
    [super removeAllConsumers];
}




@end
