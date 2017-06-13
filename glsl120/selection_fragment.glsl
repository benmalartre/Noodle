#version 120
uniform vec3 uniqueID;

void main()
{
	gl_FragColor = vec4(uniqueID,1.0);
}
