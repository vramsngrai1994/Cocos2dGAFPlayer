uniform sampler2D  u_texture;
varying highp vec2 v_texCoord[9];
varying highp vec4 vGlowColor;

void main()
{
    lowp vec4 o_color = vec4(0.0);
	o_color += texture2D(u_texture, v_texCoord[0]).a * vGlowColor * 0.05;
    o_color += texture2D(u_texture, v_texCoord[1]).a * vGlowColor * 0.09;
    o_color += texture2D(u_texture, v_texCoord[2]).a * vGlowColor * 0.12;
    o_color += texture2D(u_texture, v_texCoord[3]).a * vGlowColor * 0.15;
    o_color += texture2D(u_texture, v_texCoord[4]).a * vGlowColor * 0.18;
    o_color += texture2D(u_texture, v_texCoord[5]).a * vGlowColor * 0.15;
    o_color += texture2D(u_texture, v_texCoord[6]).a * vGlowColor * 0.12;
    o_color += texture2D(u_texture, v_texCoord[7]).a * vGlowColor * 0.09;
    o_color += texture2D(u_texture, v_texCoord[8]).a * vGlowColor * 0.05;
	gl_FragColor = o_color;
}