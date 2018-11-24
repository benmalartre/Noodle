#version 330
//uniform vec4 color;
out vec4 outColor;

in vec4 fragColor;

void main(){
	outColor = vec4(fragColor);
}
