#version 330
in vec2 st;
out vec4 outColor;

uniform sampler2D tex;
uniform vec4 color;

void main( void )
{
	outColor = texture(tex, st);

/*
	//ivec2 textureSize2d = textureSize(tex,0);
    
   vec4 t = texture2D( tex, st * 0.5 );
   vec3 c;
   if(color.a>0.5){
		if((t.r+t.g+t.b)/3>0.5)c = vec3(0);
		else c = color.xyz;
   }
   else{
		if((t.r+t.g+t.b)/3>0.5)c = color.xyz;
		else c = vec3(0);
   }
	outColor = vec4(c,0.5);
*/
}
