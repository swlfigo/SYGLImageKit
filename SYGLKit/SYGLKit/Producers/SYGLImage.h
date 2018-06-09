//
//  SYGLImage.h
//  SYGLKit
//
//  Created by Sylar on 2018/6/8.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import "SYGLProducer.h"

@class UIImage;
@interface SYGLImage : SYGLProducer

@property (retain, nonatomic) UIImage *sourceImage;
@property (readonly, nonatomic) UIImage *processedImage;
// Initialization Methods

- (instancetype)initWithUIImage:(UIImage *)image NS_DESIGNATED_INITIALIZER;
-(instancetype)init NS_UNAVAILABLE; 



@end
