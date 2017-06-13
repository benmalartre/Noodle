#version 120
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform vec3 wirecolor;

attribute vec3 position;
attribute vec3 normal;
attribute vec3 tangent;
attribute vec3 uvws;
attribute vec4 color;

varying vec3 vertex_position;
varying vec3 vertex_normal;
varying vec3 vertex_tangent;
varying vec3 vertex_uvws;
varying vec4 vertex_color;

mat4 extractRotationMatrix(mat4 m){
return mat4(m[0].xyzw,
			m[1].xyzw,
			m[2].xyzw,
			0.0,0.0,0.0,1.0);
}

void main(){
	vertex_uvws = uvws;
	vertex_color = color;
	vertex_position = vec3(view * model * vec4(position,1.0));
	mat4 rot = extractRotationMatrix(view * model);
	vertex_normal = vec3(rot * vec4(normal,1.0));
	vertex_tangent = vec3(rot * vec4(tangent,1.0));
	gl_Position = projection * vec4(vertex_position,1.0);
}
  
