uniform mat4 Projection;
uniform mat4 Modelview;

attribute highp vec4 Position;
varying highp vec4 PositionFrag;

attribute lowp vec3 Normal;
varying lowp vec3 NormalFrag;

attribute lowp vec4 ColorRaw;
varying lowp vec4 Color;

attribute lowp vec2 TexCoordRaw;
varying lowp vec2 TexCoord;

varying lowp vec3 FragmentToViewer;

void main(void)
{
    // Assign 'varying' values
    TexCoord = TexCoordRaw;
    Color = ColorRaw;
    PositionFrag = Position;
    NormalFrag = normalize(vec3(Modelview * vec4(Normal, 0.0)));
    FragmentToViewer = normalize(-(Modelview * Position).xyz);
    
    // Set the final position
    gl_Position = Projection * Modelview * Position;
}