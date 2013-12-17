////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Gaussian blur
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

attribute vec4 a_position;
attribute vec4 a_texCoord;

uniform float u_texelWidthOffset;
uniform float u_texelHeightOffset;

varying vec2 v_texCoord[5];

void main()
{
 	gl_Position = CC_MVPMatrix * a_position;
    
    vec2 t_step = vec2(u_texelWidthOffset, u_texelHeightOffset);
    v_texCoord[0] = a_texCoord.xy - t_step * 2.0;
    v_texCoord[1] = a_texCoord.xy - t_step;
    v_texCoord[2] = a_texCoord.xy;
    v_texCoord[3] = a_texCoord.xy + t_step;
    v_texCoord[4] = a_texCoord.xy + t_step * 2.0;
}