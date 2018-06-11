//
//  SYGLBlendFilter.h
//  SYGLKit
//
//  Created by Sylar on 2018/6/11.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import "SYGLTwoInputsFilter.h"


/**
    两张纹理融合滤镜
 
 可通过修改 Opacity 调整两张纹理之前的    Alpha 关系
 */
@interface SYGLBlendFilter : SYGLTwoInputsFilter

// 默认 -1.0;
// -1.0 显示只显示的是第二张传入纹理;
//  1.0 显示只显示的是第一张传入纹理;
@property (readwrite, nonatomic) float opacity;  //This property between 0.0 and 1.0 is used to set the opacity of first input texture. When it is not belong to the range above, the first input texture will be blend with the second input texture by its alpha value. Default is -1.0.

@end
