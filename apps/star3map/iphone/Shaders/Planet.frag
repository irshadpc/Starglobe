precision mediump float;

varying vec4 fragmentColor;
varying vec2 fragmentTextureCoordinates;
varying vec3 fragmentNormal;
varying vec3 lightDirection;

uniform sampler2D texture0;

void main()
{
    float light = dot(fragmentNormal, lightDirection);
   
    vec4 result = fragmentColor * texture2D(texture0, fragmentTextureCoordinates) * clamp(light, 0.1, 1.0);
    
    gl_FragColor = vec4(result.rgb, 1.0);
}
