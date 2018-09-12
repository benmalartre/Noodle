// ----------------------------------------------------
// Matrix Shader
//-----------------------------------------------------
#version 330 core

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 normal;
layout(location = 2) in vec3 tangent;
layout(location = 3) in vec3 scale;

uniform mat4 view;
out VertexData {
	vec3 position;
	vec3 normal;
	vec3 tangent;
	vec3 scale;
} outData;

void main() {
	vec4 viewNormal = normalize(view * vec4(normal, 0.0));
	vec4 viewTangent = normalize(view * vec4(tangent, 0.0));
	vec4 viewPoint = view * vec4(position, 1.0);
	outData.normal = viewNormal.xyz;
	outData.tangent = viewTangent.xyz
    outData.position = viewPoint.xyz;
	outData.scale = scale;
    gl_Position = view * vec4(position, 1.0);
};