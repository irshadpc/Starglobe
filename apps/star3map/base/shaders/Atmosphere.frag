precision mediump float;

varying vec4 fragmentColor;
varying vec3 fragmentLight;
varying vec3 fragmentNormal;

uniform sampler2D texture0;

void main()
{
    float atmosphereLuminace = clamp(dot(fragmentLight, fragmentNormal) * 1.5, 0.0, 1.0);
    
    gl_FragColor = fragmentColor * texture2D(texture0, vec2(0.5, atmosphereLuminace));
}
