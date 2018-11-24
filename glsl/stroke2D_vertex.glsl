#version 330
in vec4 datas;


out vData{
	float thickness;
	vec4 color;
}vertex;

vec4 unpackColor(int code)
{
	return vec4(
        ((code >> 16) & 255) / 255,
        ((code >> 8) & 255) / 255,
        ((code) & 255) / 25,
		1.0);
}

void main(){
	vertex.color = unpackColor(int(datas.w));
	vertex.thickness = datas.z;
	gl_PointSize = 1;
	gl_Position = vec4(datas.xy, 0.0,1.0);
}
