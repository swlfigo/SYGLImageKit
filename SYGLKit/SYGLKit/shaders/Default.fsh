varying highp vec2 textureCoordinatePort;

uniform sampler2D sourceImage;

void main()
{
    gl_FragColor = texture2D(sourceImage, textureCoordinatePort);
}
