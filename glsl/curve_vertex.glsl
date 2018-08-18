#version 330 core

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 color;
layout(location = 2) in vec3 tangent;
layout(location = 3) in float width;

uniform mat4 view;
out VertexData {
	vec3 position;
	vec3 color;
	vec3 tangent;
	float width;
} outData;

void main() {
	vec4 viewTangent = normalize(view * vec4(tangent, 0.0));
	vec4 viewPoint = view * vec4(position, 1.0);
	outData.tangent = viewTangent.xyz;
    outData.position = viewPoint.xyz;
	outData.color = color;
	outData.width = width;
    gl_Position = view * vec4(position, 1.0);
};