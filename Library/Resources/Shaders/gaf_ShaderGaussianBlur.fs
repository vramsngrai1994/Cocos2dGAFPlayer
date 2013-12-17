////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Gaussian blur
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

uniform sampler2D  u_texture;
varying highp vec2 v_texCoord[9];

void main()
{
    lowp vec4 o_color = vec4(0.0);
	o_color += texture2D(u_texture, v_texCoord[0]) * 0.05;
    o_color += texture2D(u_texture, v_texCoord[1]) * 0.09;
    o_color += texture2D(u_texture, v_texCoord[2]) * 0.12;
    o_color += texture2D(u_texture, v_texCoord[3]) * 0.15;
    o_color += texture2D(u_texture, v_texCoord[4]) * 0.18;
    o_color += texture2D(u_texture, v_texCoord[5]) * 0.15;
    o_color += texture2D(u_texture, v_texCoord[6]) * 0.12;
    o_color += texture2D(u_texture, v_texCoord[7]) * 0.09;
    o_color += texture2D(u_texture, v_texCoord[8]) * 0.05;
	gl_FragColor = o_color;
}