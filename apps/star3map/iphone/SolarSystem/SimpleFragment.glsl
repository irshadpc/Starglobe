uniform highp mat4 Modelview;

const int NumberOfTextureSlots = 3;

const int TextureSlotDayTime = 0;
const int TextureSlotNightTime = 1;
const int TextureSlotClouds = 2;

// Texture attributes (received from the application)
uniform sampler2D Textures[NumberOfTextureSlots];
uniform int TexturesEnabled[NumberOfTextureSlots];
varying lowp vec2 TexCoord;
uniform lowp vec2 OverlayTexCoord;

uniform int SunLit;
uniform highp vec3 SunPosition;

uniform highp mat4 BaseModelview;
uniform highp vec4 EntityPosition;

// Position and normal varying between vertices
varying highp vec4 PositionFrag;
varying lowp vec3 NormalFrag;

// Color of the fragment, received from the application
varying lowp vec4 Color;
uniform lowp vec4 ColorOverride;
uniform int ColorOverrideEnabled;

// Atmosphere glow effect
uniform int AtmosphereGlowEnabled;
uniform lowp float AtmosphereGlowFactor;
uniform lowp vec4 AtmosphereColorOuter;
uniform lowp vec4 AtmosphereColorInner;

varying lowp vec3 FragmentToViewer;

uniform lowp float ShadowsValue;
uniform lowp float GlowValue;
uniform lowp float CloudsValue;

// Constant values for atmosphere glow
const lowp vec3 ToViewer = vec3(0.0, 0.0, 1.0);
const lowp float AtmosphereMaxUntweenedDot = 0.1;
const lowp float AtmosphereMaxDot = 0.4;

// This function posterizes the input color, creating somewhat of a toon effect.
// A good 'posterizeVal' is 4.0
lowp vec4 posterize(lowp vec4 inputColor, lowp float posterizeVal)
{
    lowp vec4 posterize = vec4(posterizeVal, posterizeVal, posterizeVal, posterizeVal);
    lowp vec4 color = ceil(inputColor * posterize) / posterize;
    color[3] = inputColor[3];
    return color;
}

lowp vec4 pctBetweenVec4(lowp vec4 va, lowp vec4 vb, lowp float p)
{
    lowp float x = (vb.x - va.x) * p + va.x;
    lowp float y = (vb.y - va.y) * p + va.y;
    lowp float z = (vb.z - va.z) * p + va.z;
    lowp float w = (vb.w - va.w) * p + va.w;
    return vec4(x, y, z, w);
}

void main(void)
{
    lowp vec3 sunDir = normalize(vec3(BaseModelview * vec4(SunPosition, 0.0)));
    
    lowp float intensity = 1.0;
    lowp float sunDot = dot(sunDir, NormalFrag);
    sunDot = sunDot + (1.0 - sunDot) * (1.0 - ShadowsValue);
    if(SunLit != 0)
    {
        // SunLit values:   -1 = either positive or negative lights
        //                  +1 = only positive dot product lights
        //                   0 = not impacted by sun
        if(SunLit == -1)
        {
            intensity = clamp(abs(sunDot), 0.5, 1.0);
        }
        else if(SunLit == 1)
        {
            intensity = sunDot;
        }
    }
    intensity = clamp(intensity, 0.05, 1.0);
    
    lowp vec4 intensityVec = vec4(intensity, intensity, intensity, 1.0);
    
    lowp vec4 BaseColor = Color;
    if(ColorOverrideEnabled == 1)
    {
        BaseColor = ColorOverride;
    }
    lowp vec4 FinalColor = BaseColor * intensityVec;
    
    if(TexturesEnabled[0] == 1 && TexturesEnabled[1] == 1)
    {
        lowp vec4 Tex0Color = texture2D(Textures[0], TexCoord);
        lowp vec4 Tex1Color = texture2D(Textures[1], TexCoord);
        
        lowp float transitionNightDayRegion = 0.5; // On a scale of 0 to 2
        
        lowp vec4 TexColorComp = vec4(0.0, 0.0, 0.0, 0.0);
        
        if(sunDot > transitionNightDayRegion / 2.0)
        {
            TexColorComp = Tex0Color;
        }
        else if(sunDot < -transitionNightDayRegion / 2.0)
        {
            TexColorComp = Tex1Color;
        }
        else
        {
            // lowp float corDot = sunDot / 2.0 + 1.0 / 2.0;
            
            lowp float corDot = (sunDot / transitionNightDayRegion) + 0.5;
            lowp float corDotInv = 1.0 - corDot;
            
            lowp vec4 corDotV = vec4(corDot, corDot, corDot, 1.0);
            lowp vec4 corDotInvV = vec4(corDotInv, corDotInv, corDotInv, 1.0);
            
            TexColorComp = Tex0Color * corDot + Tex1Color * corDotInv;
        }
        
        FinalColor = BaseColor * TexColorComp;
    }
    else if(TexturesEnabled[0] == 1)
    {
        FinalColor *= texture2D(Textures[0], TexCoord);
    }
    else if(TexturesEnabled[1] == 1)
    {
        FinalColor *= texture2D(Textures[1], TexCoord);
    }
    
    
    // If clouds are enabled
    if(TexturesEnabled[TextureSlotClouds] == 1)
    {
        lowp float TexCoordX = TexCoord.x - floor(TexCoord.x);
        lowp float TexCoordY = TexCoord.y - floor(TexCoord.y);
        
        lowp vec2 OverlayCoord = vec2(TexCoordX - OverlayTexCoord.x, TexCoordY - OverlayTexCoord.y);
        OverlayCoord.x = OverlayCoord.x - floor(OverlayCoord.x);
        OverlayCoord.y = OverlayCoord.y - floor(OverlayCoord.y);
        
        lowp vec4 Overlay = texture2D(Textures[TextureSlotClouds], OverlayCoord);
        
        lowp float weight = sunDot * CloudsValue * Overlay.w;
        
        FinalColor = vec4((FinalColor * (1.0 - weight) + Overlay * weight).xyz, 1.0);
        
    }
    
    // Atmospheric glow!
    if(AtmosphereGlowEnabled == 1)
    {
        // Get the dot product of the vector to the viewer and the normal (determines the edge of the sphere by small values)
        lowp float PctAtmosphereGlowDot = dot(FragmentToViewer, NormalFrag);
        
        // If the dot product is in the appropriate range
        if(PctAtmosphereGlowDot < AtmosphereMaxDot)
        {
            // If the dot value is in the untweened range, make it perfectly glow!
            if(PctAtmosphereGlowDot < AtmosphereMaxUntweenedDot)
            {
                PctAtmosphereGlowDot = 0.0;
            }
            // Otherwise, it needs to tween, so we make it
            else
            {
                // Find the tween within the range
                PctAtmosphereGlowDot = (clamp(PctAtmosphereGlowDot, AtmosphereMaxUntweenedDot, AtmosphereMaxDot) - AtmosphereMaxUntweenedDot) / (AtmosphereMaxDot - AtmosphereMaxUntweenedDot);
            }
            
            // Get the percentage of glow the fragment should have
            lowp float GlowPct = (1.0 - PctAtmosphereGlowDot) * AtmosphereGlowFactor * max(intensity, 1.0 - abs(dot(sunDir, NormalFrag)));
            
            // Get the color based on the tween pct between inner and outer colors
            lowp vec4 AtmosphereColor = pctBetweenVec4(AtmosphereColorInner, AtmosphereColorOuter, GlowPct);
            
            // Recalculate the final color
            FinalColor = FinalColor * (1.0 - GlowPct * GlowValue) + AtmosphereColor * GlowPct * GlowValue;
        }
    }
    
    gl_FragColor = FinalColor;
}