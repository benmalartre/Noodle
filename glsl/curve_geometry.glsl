#version 330 core
layout(lines) in;
layout(triangle_strip, max_vertices = 4) out;
uniform mat4 projection;

in VertexData {
	vec3 position;
	vec3 color;
	vec3 tangent;
	float width;
} inData[];

out FragData {
	vec3 position;
	vec3 color;
	vec3 normal;
} outData;

void main() {
	vec3 viewDir = normalize(-gl_in[0].gl_Position.xyz);
	vec3 cvBiNormal0 = normalize(cross(viewDir, inData[0].tangent));
	vec3 cvBiNormal1 = normalize(cross(viewDir, inData[1].tangent));
	vec3 cvNormal0 = normalize(cross(cvBiNormal0, inData[0].tangent));
	vec3 cvNormal1 = normalize(cross(cvBiNormal1, inData[1].tangent));
	vec4 right0 = vec4(cvBiNormal0, 1.0) * inData[0].width;
	vec4 right1 = vec4(cvBiNormal1, 1.0) * inData[1].width;

	outData.normal = cvNormal0;
	outData.color = inData[0].color;
	outData.position = inData[0].position;
	gl_Position = projection * (gl_in[0].gl_Position - right0);
	EmitVertex();
	gl_Position = projection * (gl_in[0].gl_Position + right0);
	EmitVertex();

	outData.normal = cvNormal1;
	outData.color = inData[1].color;
	outData.position = inData[1].position;
	gl_Position = projection * (gl_in[1].gl_Position - right1);
	EmitVertex();
	gl_Position = projection * (gl_in[1].gl_Position + right1);
	EmitVertex();
	EndPrimitive();
};