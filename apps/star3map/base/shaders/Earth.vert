precision lowp float;

attribute vec4 position;
attribute vec3 normal;
attribute vec2 texureCoordinates;
attribute vec3 tangent;
attribute vec3 binormal;

uniform mat4 matrix;
uniform mat3 modelViewMatrix;
uniform mat4 modelViewMatrix4x4;
uniform vec4 diffuseColor;
uniform vec3 sunPosition;

varying vec4 fragmentColor;
varying vec2 fragmentTextureCoordinates;
varying vec3 fragmentWorldPosition;
varying vec3 fragmentNormal;
varying vec3 lightDirection;
varying vec3 sunDirection;

void main()
{
	gl_Position                = matrix * position;
	fragmentColor              = diffuseColor;
	fragmentTextureCoordinates = texureCoordinates;
    fragmentWorldPosition      = (modelViewMatrix4x4 * position).xyz;
    fragmentNormal             = modelViewMatrix * normal;
    sunDirection               = modelViewMatrix * sunPosition;
	lightDirection             = vec3(dot(sunDirection, modelViewMatrix * tangent), dot(sunDirection, modelViewMatrix * binormal), dot(sunDirection, fragmentNormal));
}
