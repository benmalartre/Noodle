#version 330

//precision highp float;
layout(lines_adjacency) in;
layout(triangle_strip) out;
layout(max_vertices = 4) out;

in vData{
	float thickness;
	vec4 color;
}vertices[];

out vec4 fragColor;

void main(){
	float thick1 = vertices[1].thickness;
	float thick2 = vertices[2].thickness;
	vec3 a = gl_in[0].gl_Position.xyz;
	vec3 b = gl_in[1].gl_Position.xyz;
	vec3 c = gl_in[2].gl_Position.xyz;
	vec3 d = gl_in[3].gl_Position.xyz;

	vec3 dir = c-b;
	vec3 norm = normalize(cross(dir,vec3(0,0,1)));
	vec3 tan1 = normalize(b-a);
	vec3 tan2 = normalize(d-c);
	vec3 miter1 = vec3(-tan1.y,tan1.x,0);
	vec3 miter2 = vec3(-tan2.y,tan2.x,0);
	float length1 = thick1/dot(norm,miter1);
	float length2 = thick2/dot(norm,miter2);
	
	fragColor = vertices[1].color;
	gl_Position = vec4(b-norm*thick1,1);EmitVertex();
	gl_Position = vec4(b+norm*thick1,1);EmitVertex();
	fragColor = vertices[2].color;
	gl_Position = vec4(c-norm*thick2,1);EmitVertex();
	gl_Position = vec4(c+norm*thick2,1);EmitVertex();

	EndPrimitive();
}
