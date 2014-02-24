////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Gaussian blur
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

attribute vec4 a_position;
attribute vec4 a_texCoord;

uniform float u_texelWidthOffset;
uniform float u_texelHeightOffset;

varying vec2 v_texCoord[9];

void main()
{
 	gl_Position = CC_MVPMatrix * a_position;
    
 	int t_multiplier = 0;
    vec2 t_step = vec2(u_texelWidthOffset, u_texelHeightOffset);
    
 	for (int i = 0; i < 9; i++)
    {
 		t_multiplier = (i - 4);
 		v_texCoord[i] = a_texCoord.xy + float(t_multiplier) * t_step;
 	}
}