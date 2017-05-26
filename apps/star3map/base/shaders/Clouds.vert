precision lowp float;

attribute vec4 position;
attribute vec3 normal;
attribute vec2 texureCoordinates;

uniform mat4 matrix;
uniform mat3 modelViewMatrix;
uniform vec4 diffuseColor;
uniform vec3 sunPosition;
uniform float cloudsHeight;

varying vec4 fragmentColor;
varying vec2 fragmentTextureCoordinates;
varying vec3 fragmentLight;
varying vec3 fragmentNormal;

void main()
{
    float scale                = 1.0 + cloudsHeight;
    vec4 scaledPosition        = vec4(position.x * scale, position.y * scale, position.z * scale, position.w);
	gl_Position                = matrix * scaledPosition;
	fragmentColor              = diffuseColor;
	fragmentTextureCoordinates = texureCoordinates;
    fragmentLight              = modelViewMatrix * sunPosition;
	fragmentNormal             = modelViewMatrix * normal;
}
