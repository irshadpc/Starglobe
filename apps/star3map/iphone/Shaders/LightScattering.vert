precision lowp float;

attribute vec4 position;
attribute vec2 textureCoordinates;

varying vec2 fragmentTextureCoordinates;

void main()
{
	gl_Position                = position;
    fragmentTextureCoordinates = textureCoordinates;
}
