//
//  SYGLProgram.m
//  OpenGLES 01
//
//  Created by Sylar on 2017/11/21.
//  Copyright © 2017年 Sylar. All rights reserved.
//

#import "SYGLProgram.h"

@interface SYGLProgram()
{
    NSMutableDictionary *attributes_;
    NSMutableDictionary *uniforms_;
}
@end

@implementation SYGLProgram
- (void)dealloc
{
    if (vertShader)
        glDeleteShader(vertShader);
    
    if (fragShader)
        glDeleteShader(fragShader);
    
    if (program)
        glDeleteProgram(program);
    
}


-(id)initWithVertexShaderString:(NSString *)vShaderString fragmentShaderString:(NSString *)fShaderString{
    if (self = [super init]) {
        attributes_ = [[NSMutableDictionary alloc] init];
        uniforms_ = [[NSMutableDictionary alloc] init];
        
        program = glCreateProgram();
        
        //顶点Shader
        if (![self compileShader:&vertShader
                            type:GL_VERTEX_SHADER
                          string:vShaderString])
        {
            NSLog(@"Failed to compile vertex shader");
        }
        
        
        //FragmentShader
        if (![self compileShader:&fragShader
                            type:GL_FRAGMENT_SHADER
                          string:fShaderString])
        {
            NSLog(@"Failed to compile fragment shader");
        }
        
        glAttachShader(program, vertShader);
        glAttachShader(program, fragShader);
        
        [self link];
    }
    return self;
}


- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename
            fragmentShaderFilename:(NSString *)fShaderFilename;
{
    NSString *vertShaderPathname = [[NSBundle mainBundle] pathForResource:vShaderFilename ofType:@"vsh"];
    NSString *vertexShaderString = [NSString stringWithContentsOfFile:vertShaderPathname encoding:NSUTF8StringEncoding error:nil];
    
    NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:fShaderFilename ofType:@"fsh"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:fragShaderPathname encoding:NSUTF8StringEncoding error:nil];
    
    if ((self = [self initWithVertexShaderString:vertexShaderString fragmentShaderString:fragmentShaderString]))
    {
    }

    return self;
}

- (BOOL)compileShader:(GLuint *)shader
                 type:(GLenum)type
               string:(NSString *)shaderString
{
    GLint status;
    const GLchar *source;
    
    source =
    (GLchar *)[shaderString UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    
    if (status != GL_TRUE)
    {
    }

    
    return status == GL_TRUE;
}


- (GLuint)uniformIndex:(NSString *)uniformName
{
    return glGetUniformLocation(program, [uniformName UTF8String]);
}

//绑定Program
- (BOOL)link
{
    GLint status;
    
    glLinkProgram(program);
    
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE)
        return NO;
    
    if (vertShader)
    {
        glDeleteShader(vertShader);
        vertShader = 0;
    }
    if (fragShader)
    {
        glDeleteShader(fragShader);
        fragShader = 0;
    }
    
    return YES;
}

-(void)use
{
    glUseProgram(program);
}

- (void)draw
{
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


#pragma mark - Set Shader Uniform

#pragma mark - Getting Attribute or Uniform Location Methods

- (NSNumber *)locationForAttributeName:(NSString *)attributeName
{
    NSNumber *attributeLocation = [attributes_ objectForKey:attributeName];
    if (!attributeLocation) {
        GLint location = glGetAttribLocation(program, [attributeName UTF8String]);
        glEnableVertexAttribArray(location);
        
        attributeLocation = [NSNumber numberWithInt:location];
        [attributes_ setObject:attributeLocation forKey:attributeName];
    }
    return attributeLocation;
}

- (NSNumber *)locationForUniformName:(NSString *)uniformName
{
    NSNumber *uniformLocation = [uniforms_ objectForKey:uniformName];
    if (!uniformLocation) {
        GLint location = glGetUniformLocation(program, [uniformName UTF8String]);
        uniformLocation = [NSNumber numberWithInt:location];
        [uniforms_ setObject:uniformLocation forKey:uniformName];
    }
    return uniformLocation;
}

#pragma mark - Setting Attribute Methods

- (void)setCoordinatePointer:(const GLfloat *)pointer coordinateSize:(GLint)size forAttribute:(NSString *)attributeName
{
    NSNumber *attributeLocation = [self locationForAttributeName:attributeName];
    
    glVertexAttribPointer([attributeLocation intValue], size, GL_FLOAT, GL_FALSE, 0, pointer);
}

#pragma mark - Setting Uniform Methods

- (void)setInt:(int)intValue forUniform:(NSString *)uniformName
{
    NSNumber *uniformLocation = [self locationForUniformName:uniformName];
    
    glUniform1i([uniformLocation intValue], intValue);
}

- (void)setIntArray:(int *)intArray withArrayCount:(int)count forUniform:(NSString *)uniformName
{
    NSNumber *uniformLocation = [self locationForUniformName:uniformName];
    
    glUniform1iv([uniformLocation intValue], count, intArray);
}

- (void)setFloat:(float)floatValue forUniform:(NSString *)uniformName
{
    NSNumber *uniformLocation = [self locationForUniformName:uniformName];
    
    glUniform1f([uniformLocation intValue], floatValue);
}

- (void)setTextureIndex:(int)index forTexture:(NSString *)textureName
{
    [self setInt:index forUniform:textureName];
}

- (void)setFloatArray:(float *)floatArray withArrayCount:(int)count forUniform:(NSString *)uniformName
{
    NSNumber *uniformLocation = [self locationForUniformName:uniformName];
    
    glUniform1fv([uniformLocation intValue], count, floatArray);
}


- (void)set4x4Matrix:(float *)matrix forUniform:(NSString *)uniformName
{
    NSNumber *uniformLocation = [self locationForUniformName:uniformName];
    
    glUniformMatrix4fv([uniformLocation intValue], 1, GL_FALSE, matrix);
}


@end
