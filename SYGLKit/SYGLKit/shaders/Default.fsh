/* 
  Default.fsh


  Created by Kwan Yiuleung on 14-3-15.
  Copyright (c) 2014年 Kwan Yiuleung. All rights reserved.
*/

varying highp vec2 textureCoordinatePort;

uniform sampler2D sourceImage;

void main()
{
    gl_FragColor = texture2D(sourceImage, textureCoordinatePort);
}
