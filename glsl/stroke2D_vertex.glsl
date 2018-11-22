#version 150
in vec3 vps;
in vec3 vc;

out vData{
	float thickness;
	vec3 color;
}vertex;

void main(){
	vertex.color = vc;
	vertex.thickness = vps.z;
	//gl_PointSize = vps.z;
	gl_Position = vec4(vps.xy,0,1);
}
