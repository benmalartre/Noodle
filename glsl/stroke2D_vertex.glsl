#version 330
in vec4 datas;


out vData{
	float thickness;
	vec4 color;
}vertex;

/*
vec4 unpackColor(uint code)
{
	return vec4(
        float((code & uint(0xff000000)) >> 16),
		float((code & uint(0x00ff0000)) >> 8),
		float((code & uint(0x0000ff00))),
		1);
}
*/
vec4 unpackColor(float f) 
{
    vec4 color;

    color.r = floor(f / 256.0 / 256.0);
    color.g = floor((f - color.r * 256.0 * 256.0) / 256.0);
    color.b = floor(f - color.r * 256.0 * 256.0 - color.g * 256.0);
	color.a = 255;
    // now we have a vec3 with the 3 components in range [0..256]. Let's normalize it!
    return color / 256.0;
}
void main(){
	vertex.color = unpackColor(datas.a);
	vertex.thickness = datas.z;
	gl_PointSize = 1;
	gl_Position = vec4(datas.xy, 0.0,1.0);
}
