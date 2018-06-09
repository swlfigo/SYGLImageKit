//
//  SYGLView.h
//  SYGLKit
//
//  Created by Sylar on 2018/6/7.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYGLConsumer.h"

@class SYGLFrameBuffer;
@class SYGLTexture;
@class SYGLProgram;

@interface SYGLView : UIView<SYGLConsumer>
{
    BOOL enabled_;
    SYGLFrameBuffer *displayFBO_;
    SYGLTexture *inputTexture_;
    SYGLProgram *displayProgram_;
    CGSize contentSize_;
    SYGLConsumerContentMode contentMode_;
    NSMutableArray *producers_;
}
@end
