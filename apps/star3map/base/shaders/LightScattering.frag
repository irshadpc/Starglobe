precision highp float;

varying vec2 fragmentTextureCoordinates;

uniform vec2 sunPosition;
uniform sampler2D texture0;

void main()
{
    int samplesNumber = 16;
    float density = 0.9;
    float decay = 0.99;
    float exposure = 1.5;
    
    vec2 delta = (fragmentTextureCoordinates - sunPosition) / float(samplesNumber) * density;
	vec2 textureCoordinates = fragmentTextureCoordinates;
	vec3 scatter = texture2D(texture0, textureCoordinates).rgb;
	float illuminationDecay = 1.0;

	for(int i = 0; i < samplesNumber; i++)
    {
		textureCoordinates -= delta;
		scatter            += texture2D(texture0, textureCoordinates).rgb * illuminationDecay;
		illuminationDecay  *= decay;
	}
    
	scatter /= float(samplesNumber);

	gl_FragColor = vec4(scatter * exposure, 1.0);
}
