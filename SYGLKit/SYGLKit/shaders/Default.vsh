/* 
  Default.vsh


  Created by Kwan Yiuleung on 14-3-15.
  Copyright (c) 2014年 Kwan Yiuleung. All rights reserved.
*/

attribute vec4 position;
attribute vec2 textureCoordinate;

varying vec2 textureCoordinatePort;

void main()
{
    textureCoordinatePort = textureCoordinate;
    
    gl_Position = position;
}
