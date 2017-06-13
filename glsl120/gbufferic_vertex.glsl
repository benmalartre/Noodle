#version 120

mat4 rotationMatrix(vec3 axis, float angle){
	axis = normalize(axis);
	float s = sin(angle);
	float c = cos(angle);
	float oc = 1.0 - c;
	return mat4(oc*axis.x*axis.x+c,			oc*axis.x*axis.y-axis.z*s,		oc*axis.z*axis.x+axis.y*s, 	0.0,
				oc*axis.x*axis.y+axis.z*s,	oc*axis.y*axis.y+c,				oc*axis.y*axis.z-axis.x*s,	0.0,
				oc*axis.z*axis.x-axis.y*s,	oc*axis.y*axis.z+axis.x*s,		oc*axis.z*axis.z+c,			0.0,
				0.0,						0.0,							0.0,						1.0);
}

mat4 directionFromTwoVectors(vec3 dir,vec3 up){

	dir = normalize(dir);
	up = normalize(up);
	vec3 norm = cross(dir,up);
	norm = normalize(norm);
	
	up = cross(norm,dir);
	up = normalize(up);
	
	return mat4(up.x,dir.x,norm.x,0.0,
				up.y,dir.y,norm.y,0.0,
				up.z,dir.z,norm.z,0.0,
				0.0,0.0,0.0,1.0);
	/*
	return mat4(norm.x,up.x,-dir.x,0.0,
				norm.y,up.y,-dir.y,0.0,
				norm.z,up.z,-dir.z,0.0,
				0.0,0.0,0.0,1.0);
	*/
				
}
uniform mat4 view;
uniform mat4 projection;
uniform mat4 model;
uniform float nearplane;
uniform float farplane;

attribute vec3 s_pos;
attribute vec3 s_norm;
attribute vec3 s_uvws;
attribute vec3 position;
attribute vec3 normal;
attribute vec3 tangent;
attribute vec4 color;
attribute vec3 scale;
attribute float size;

varying vec3 vertex_position;
varying vec3 vertex_normal;
varying vec3 vertex_color;

void main(){
	

	vertex_color = color.xyz;

	mat4 rot = directionFromTwoVectors(normal,tangent);
	vec4 sshape = vec4(s_pos*scale*size,1.0)*rot;
	vec4 rshape = vec4(position+sshape.xyz,1.0);
	vec4 viewPos = view * model * rshape;
	vertex_position = viewPos.xyz;
	gl_Position = projection * viewPos;

	mat3 normalMatrix = mat3(view*model);//transpose(inverse(mat3(view* model)));
	vec4 snorm = vec4(s_norm*scale*size,0.0)*rot;
	vertex_normal = normalMatrix * normalize(snorm.xyz);
}
 
 
