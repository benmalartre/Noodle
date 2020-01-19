#version 330
in vec3 inColor;
uniform sampler2D image;

out vec4 outColor;


void main(){

	outColor = vec4(1.0,0.0,0.0,1.0);//texture(image,gl_PointCoord) * vec4(inColor,1.0);

}
