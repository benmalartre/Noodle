#version 150

precision highp float;
layout(lines_adjacency) in;
layout(triangle_strip) out;
layout(max_vertices = 4) out;

in vData{
	float thickness;
	vec3 color;
}vertices[];

out vec4 fragColor;

void main(){
	float thick = vertices[0].thickness;
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
	float length1 = thick/dot(norm,miter1);
	float length2 = thick/dot(norm,miter2);
	fragColor = vec4(vertices[0].color,1);
	gl_Position = vec4(b-norm*thick,1);EmitVertex();
	gl_Position = vec4(b+norm*thick,1);EmitVertex();
	gl_Position = vec4(c-norm*thick,1);EmitVertex();
	gl_Position = vec4(c+norm*thick,1);EmitVertex();
	EndPrimitive();
}
