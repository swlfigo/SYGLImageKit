attribute vec4 position;
attribute vec2 textureCoordinate;

varying vec2 textureCoordinatePort;

void main()
{
    textureCoordinatePort = textureCoordinate;
    
    gl_Position = position;
}
