#version 120
attribute vec3 coords;
uniform mat4 P, V;
varying vec3 texcoords;
void main(void){
	texcoords = coords;
	gl_Position = P * V * vec4(coords.xyz,1.0);
}