#version 330
in vec4 datas;


out vData{
	float thickness;
	vec4 color;
}vertex;

vec4 unpackColor(uint code)
{
	return vec4(
        float((code & uint(0xff000000)) >> 16),
		float((code & uint(0x00ff0000)) >> 8),
		float((code & uint(0x0000ff00))),
		1);
}

void main(){
	vertex.color = unpackColor(uint(datas.w));
	vertex.thickness = datas.z;
	gl_PointSize = 1;
	gl_Position = vec4(datas.xy, 0.0,1.0);
}
