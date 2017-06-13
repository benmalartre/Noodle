#version 120
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform mat4 offset;
attribute vec3 position;
void main(){
	gl_Position = projection * view *  model *offset*vec4(position,1.0);
}
