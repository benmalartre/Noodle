#version 120

uniform mat4 view;
uniform mat4 projection;
uniform mat4 model;
uniform mat4 invmodelview;
uniform float nearplane;
uniform float farplane;

attribute vec3 position;
attribute vec3 normal;
attribute vec3 color;

varying vec3 vertex_position;
varying vec3 vertex_normal;
varying vec3 vertex_color;


void main(){
	vec4 viewPos =  view*model * vec4(position, 1.0f);
    vertex_position = viewPos.xyz;
    gl_Position = projection * viewPos;
    //vertex_normal = normal;
    mat3 normalMatrix = transpose(mat3(invmodelview));
    vertex_normal = normalMatrix * normal;
    vertex_color = color;
}
 
