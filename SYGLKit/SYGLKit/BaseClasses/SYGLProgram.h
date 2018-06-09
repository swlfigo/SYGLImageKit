//
//  SYGLProgram.h
//  OpenGLES 01
//
//  Created by Sylar on 2017/11/21.
//  Copyright © 2017年 Sylar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


@interface SYGLProgram : NSObject
{
    GLuint          program,
                    vertShader,
                    fragShader;
}

//根据ShaderString初始化
- (id)initWithVertexShaderString:(NSString *)vShaderString
            fragmentShaderString:(NSString *)fShaderString;
//根据Bundle中文件初始化
- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename
            fragmentShaderFilename:(NSString *)fShaderFilename;


//获取位置
- (GLuint)uniformIndex:(NSString *)uniformName;

//使用Program
- (void)use;
- (void)draw;

- (void)setCoordinatePointer:(const GLfloat *)pointer coordinateSize:(GLint)size forAttribute:(NSString *)attributeName;

- (void)setInt:(int)intValue forUniform:(NSString *)uniformName;
- (void)setIntArray:(int *)intArray withArrayCount:(int)count forUniform:(NSString *)uniformName;
- (void)setFloat:(float)floatValue forUniform:(NSString *)uniformName;
- (void)setTextureIndex:(int)index forTexture:(NSString *)textureName;
- (void)setFloatArray:(float *)floatArray withArrayCount:(int)count forUniform:(NSString *)uniformName;
- (void)set4x4Matrix:(float *)matrix forUniform:(NSString *)uniformName;

@end
