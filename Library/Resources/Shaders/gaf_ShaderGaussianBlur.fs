////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Gaussian blur
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

uniform sampler2D  u_texture;
varying highp vec2 v_texCoord[5];

void main()
{
    lowp vec4 o_color = vec4(0.0);
	o_color += texture2D(u_texture, v_texCoord[0]) * 0.204164;
	o_color += texture2D(u_texture, v_texCoord[1]) * 0.304005;
	o_color += texture2D(u_texture, v_texCoord[2]) * 0.304005;
	o_color += texture2D(u_texture, v_texCoord[3]) * 0.093913;
	o_color += texture2D(u_texture, v_texCoord[4]) * 0.093913;
	gl_FragColor = o_color;
}