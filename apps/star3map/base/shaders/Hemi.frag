precision lowp float;

varying vec4 fragmentColor;
varying vec2 fragmentTextureCoordinates;

uniform sampler2D texture0;
uniform sampler2D texture1;
uniform float transition;

void main()
{
	vec4 from = texture2D(texture0, fragmentTextureCoordinates);
	vec4 to = texture2D(texture1, fragmentTextureCoordinates);

	gl_FragColor = fragmentColor * vec4((from + (to - from) * transition).xyz, 1.0);
}
