//
//  SYGLTwoInputsFilter.h
//  SYGLKit
//
//  Created by Sylar on 2018/6/10.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import "SYGLFilter.h"



/**
    两张纹理融合滤镜
 
 @discussion:
 
1.此滤镜用于两张纹理融合,使用方法将两个 Filter 添加此 Filter
 eg: [Filter addConsumer: TwoInputFilter];
 
 默认的纹理大小与定点坐标以第一个传入 Filter 的 ContentSize 与 Outputframe 决定;
 
 第二张纹理根据着色器,与第一张纹理同时同一个像素位置开始绘制,不能自定义位置,若需要自定义位置,需要用到 SYGLTwoPassesFilter , 此滤镜只做简单的叠加,位置都是从 (0,0) 点开始
 
 2. 如果需要调整每张纹理直接混合时候的透明度,需要使用 SYGLBlendFilter , 通过传入参数 Opacity 调整纹理之间融合的 Alpha
 */
@interface SYGLTwoInputsFilter : SYGLFilter
{
    SYGLTexture *secondInputTexture_;
}
@end
