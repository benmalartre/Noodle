#version 120
uniform int selected;
varying vec3 inColor;
varying vec3 inUVWs;
varying vec3 inNorm;


uniform sampler2D tex;
uniform vec3 datas;

void main(){
	/*
	vec4 t = texture(tex,inUVWs.xz);
	float a = 0.0;
	if((t.r+t.g+t.b)<0.5)a = 1.0;
	outColor = vec4(inColor*0.1+vec3(0.666,0.666,0.666),a);
	*/
	vec3 nn = normalize((inNorm+1)/2);
	gl_FragColor = vec4(1.0,0.0,0.0,1.0);//vec4(inColor,1.0);// * vec4(nn,1);
	//outColor = vec4(texture(tex,inUVWs.xz).xyz,1.0) * vec4(inColor,1.0);
	//outColor = vec4(inColor,1.0);
	//outColor = vec4(texture(tex,inUVWs.xz).xyz,1.0);//vec4(inUVWs,1.0);//*d;//vec4(inColor,1.0)* vec4((inNorm+1)/2,1);
	//outColor = vec4(inColor,1.0);
}
