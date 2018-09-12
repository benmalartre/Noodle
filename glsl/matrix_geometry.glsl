#version 330 core
layout(points) in;
layout(triangle_strip, max_vertices = 4) out;
uniform mat4 projection;

in VertexData {
	vec3 position;
	vec3 normal;
	vec3 tangent;
	vec3 scale;
} inData[];

out FragData {
	vec3 position;
	vec3 color;
	vec3 normal;
} outData;

void main() {
/*
	vec3 viewDir = normalize(-gl_in[0].gl_Position.xyz);
	vec3 tangent = inData[1].position - inData[0].position;
	normalize(tangent);
	vec3 cvBiTangent0 = normalize(cross(viewDir, inData[0].normal));
	vec3 cvBiTangent1 = normalize(cross(viewDir, inData[1].normal));
	vec3 cvTangent0 = normalize(cross(cvBiTangent0, inData[0].normal));
	vec3 cvTangent1 = normalize(cross(cvBiTangent1, inData[1].normal));
	vec4 right0 = vec4(cvTangent0, 1.0) * inData[0].width;
	vec4 right1 = vec4(cvTangent1, 1.0) * inData[1].width;

	outData.normal = inData[0].normal;
	outData.color = inData[0].color;
	outData.position = inData[0].position;
	gl_Position = projection * (gl_in[0].gl_Position - right0);
	EmitVertex();
	gl_Position = projection * (gl_in[0].gl_Position + right0);
	EmitVertex();

	outData.normal = inData[1].normal;
	outData.color = inData[1].color;
	outData.position = inData[1].position;
	gl_Position = projection * (gl_in[1].gl_Position - right1);
	EmitVertex();
	gl_Position = projection * (gl_in[1].gl_Position + right1);
	EmitVertex();
	EndPrimitive();
	*/
};