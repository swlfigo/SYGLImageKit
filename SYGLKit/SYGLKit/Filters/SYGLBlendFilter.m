//
//  SYGLBlendFilter.m
//  SYGLKit
//
//  Created by Sylar on 2018/6/11.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import "SYGLBlendFilter.h"

@implementation SYGLBlendFilter

- (instancetype)init
{
    self = [super init];
    if (self) {
        _opacity = -1.0f;
    }
    return self;
}


+(NSString *)fragmentShaderFilename{
    static NSString *fName = @"Blend";
    return fName;
}

-(void)setOpacity:(float)opacity{
    _opacity = opacity;
    
}

-(void)setProgramUniform{
    [super setProgramUniform];
    [filterProgram_ setFloat:_opacity forUniform:@"opacity"];
}

@end
