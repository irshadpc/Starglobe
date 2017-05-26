precision highp float;

varying vec4 fragmentColor;
varying vec2 fragmentTextureCoordinates;

uniform float currentTime;
uniform float nightFactor;
uniform sampler2D texture0;
uniform sampler2D texture1;

float epsilon = 1e-10;

vec3 HUE2RGB(float hue)
{
	float red = abs(hue * 6.0 - 3.0) - 1.0;
	float green = 2.0 - abs(hue * 6.0 - 2.0);
	float blue = 2.0 - abs(hue * 6.0 - 4.0);
	return clamp(vec3(red, green, blue), 0.0, 1.0);
}

vec3 HSL2RGB(vec3 HSLValue)
{
	vec3 RGBValue = HUE2RGB(HSLValue.x);
	float chroma = (1.0 - abs(2.0 * HSLValue.z - 1.0)) * HSLValue.y;
	return (RGBValue - 0.5) * chroma + HSLValue.z;
}

vec3 RGB2HCV(vec3 RGBValue)
{
	vec4 P = (RGBValue.g < RGBValue.b) ? vec4(RGBValue.bg, -1.0, 2.0 / 3.0) : vec4(RGBValue.gb, 0.0, -1.0 / 3.0);
	vec4 Q = (RGBValue.r < P.x) ? vec4(P.xyw, RGBValue.r) : vec4(RGBValue.r, P.yzx);
	float chroma = Q.x - min(Q.w, Q.y);
	float hue = abs((Q.w - Q.y) / (6.0 * chroma + epsilon) + Q.z);
	return vec3(hue, chroma, Q.x);
}

vec3 RGB2HSL(vec3 RGBValue)
{
	vec3 HCVValue = RGB2HCV(RGBValue);
	float luminace = HCVValue.z - HCVValue.y * 0.5;
	float saturate = HCVValue.y / (1.0 - abs(luminace * 2.0 - 1.0) + epsilon);
	return vec3(HCVValue.x, saturate, luminace);
}

void main()
{
	float uShift = mod(currentTime / 3600.0, 2.0);

    vec2 turbulancesUV = mod((fragmentTextureCoordinates + vec2(uShift, uShift * 0.5)), 1.0);

	float heat = texture2D(texture0, turbulancesUV).r;
    vec4 result = fragmentColor * texture2D(texture1, vec2(heat, 0.5));
    
    gl_FragColor = vec4(result.rgb, 1.0);
}
