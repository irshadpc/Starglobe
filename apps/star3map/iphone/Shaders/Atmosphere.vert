precision lowp float;

attribute vec4 position;
attribute vec3 normal;

uniform mat4 matrix;
uniform mat3 modelViewMatrix;
uniform mat4 modelViewMatrix4x4;
uniform vec4 diffuseColor;
uniform vec3 sunPosition;
uniform float atmosphereHeight;

varying vec4 fragmentColor;
varying vec3 fragmentLight;
varying vec3 fragmentNormal;

void main()
{
    float scale           = 1.0 + atmosphereHeight;
    vec4 scaledPosition   = vec4(position.x * scale, position.y * scale, position.z * scale, position.w);
	gl_Position           = matrix * scaledPosition;
	fragmentColor         = diffuseColor;
    fragmentLight         = modelViewMatrix * sunPosition;
	fragmentNormal        = modelViewMatrix * normal;
}
