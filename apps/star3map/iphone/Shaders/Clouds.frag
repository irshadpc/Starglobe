precision highp float;

varying vec4 fragmentColor;
varying vec2 fragmentTextureCoordinates;
varying vec3 fragmentLight;
varying vec3 fragmentNormal;

uniform float currentTime;
uniform float cloudsSpeed;
uniform sampler2D texture0;

void main()
{
    float light = dot(fragmentNormal, fragmentLight);
    float uShift = mod(currentTime / cloudsSpeed, 1.0);
    vec2 cloudsUV = mod(fragmentTextureCoordinates + vec2(uShift, 0.0), 1.0);
    float clouds = texture2D(texture0, cloudsUV).r;
    
    gl_FragColor = fragmentColor * vec4(1.0, 1.0, 1.0, clouds) * clamp(light, 0.1, 1.0);
}
