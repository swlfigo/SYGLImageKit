/*
    两纹理融合FSH,根据 opacity 调整纹理之间透明度关系
 */

varying highp vec2 textureCoordinatePort;
varying highp vec2 secondTextureCoordinatePort;

uniform sampler2D sourceImage;
uniform sampler2D secondSourceImage;
uniform lowp float opacity;

void main()
{
    lowp vec4 sourceColor = texture2D(sourceImage, textureCoordinatePort);
    lowp vec4 secondSourceColor = texture2D(secondSourceImage, secondTextureCoordinatePort);
    
    if (opacity < 0.0 || opacity > 1.0) {
        sourceColor.rgb = mix(sourceColor.rgb, secondSourceColor.rgb, (1.0 - sourceColor.a));
    }
    else {
        sourceColor.rgb = mix(sourceColor.rgb, secondSourceColor.rgb, opacity);
    }
    
    sourceColor.a = max(sourceColor.a, secondSourceColor.a);
    
    gl_FragColor = sourceColor;
}
