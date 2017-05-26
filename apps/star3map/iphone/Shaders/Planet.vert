precision lowp float;

attribute vec4 position;
attribute vec3 normal;
attribute vec2 texureCoordinates;

uniform mat4 matrix;
uniform mat3 modelViewMatrix;
uniform vec4 diffuseColor;
uniform vec3 sunPosition;

varying vec4 fragmentColor;
varying vec2 fragmentTextureCoordinates;
varying vec3 fragmentNormal;
varying vec3 lightDirection;

void main()
{
	gl_Position                = matrix * position;
	fragmentColor              = diffuseColor;
	fragmentTextureCoordinates = texureCoordinates;
    fragmentNormal             = modelViewMatrix * normal;
    lightDirection             = modelViewMatrix * sunPosition;
}
