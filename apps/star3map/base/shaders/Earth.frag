precision mediump float;

varying vec4 fragmentColor;
varying vec2 fragmentTextureCoordinates;
varying vec3 fragmentWorldPosition;
varying vec3 fragmentNormal;
varying vec3 lightDirection;
varying vec3 sunDirection;

uniform float currentTime;
uniform float cloudsSpeed;
uniform sampler2D texture0;
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform sampler2D texture3;
uniform sampler2D texture4;

void main()
{
    vec3 normal = normalize(texture2D(texture1, fragmentTextureCoordinates).rgb * 2.0 - 1.0);
    float light = dot(normal, lightDirection);
    float luminace = texture2D(texture2, fragmentTextureCoordinates).r * (1.0 - clamp(light * 7.0, 0.0, 1.0));
    float uShift = mod(currentTime / cloudsSpeed, 1.0);
    vec2 cloudsUV = mod(fragmentTextureCoordinates + vec2(uShift, 0.0), 1.0);
    float clouds = 1.0 - texture2D(texture3, cloudsUV).r / 2.0;
    float water = texture2D(texture4, fragmentTextureCoordinates).r;
	vec3 halfVector = normalize(sunDirection + normalize(-fragmentWorldPosition));
	float specularLight = pow(clamp(dot(fragmentNormal, halfVector), 0.0, 1.0), 8.0) / 4.0;
    vec4 specularColor = vec4(1.0, 1.0, 1.0, 1.0) * specularLight * 1.5;// * water * light;
    
    vec4 result = (fragmentColor * texture2D(texture0, fragmentTextureCoordinates) * clamp(light, 0.1, 1.0) + luminace * vec4(1.0, 0.56, 0.0, 1.0)) * clouds;
    
    gl_FragColor = vec4(result.rgb, 1.0);
}
