#version 120
varying vec3 texcoords;
uniform samplerCube cube_tex;

void main(){
	gl_FragColor = textureCube(cube_tex,texcoords);
}