#version 120

varying vec3 vertex_position;
varying vec3 vertex_normal;
varying vec3 vertex_color;

uniform float nearplane;
uniform float farplane;

uniform sampler2D tex;
uniform mat4 view;

/*
varying vec4 position;
varying vec4 normal;
varying vec4 color;
*/
float linearizeDepth(float depth)
{
    float z = depth * 2.0 - 1.0; // Back to NDC 
    return (2.0 * nearplane * farplane) / (farplane + nearplane - z * (farplane - nearplane));	

}

void main()
{
    
    // Store the fragment position vector in the first gbuffer texture
    gl_FragData[0] = vec4(vertex_position,linearizeDepth(gl_FragCoord.z));
	
    // And store linear depth into gPositionDepth's alpha component
    //gl_FragData[0].a = linearizeDepth(gl_FragCoord.z); // Divide by FAR if you need to store depth in range 0.0 - 1.0 (if not using floating point colorbuffer)
 
	// Also store the per-fragment normals into the gbuffer
    gl_FragData[1] = vec4(normalize(vertex_normal),0.0);
	
    // And the diffuse per-fragment color
    gl_FragData[2] = vec4(vertex_color,0.0); // Currently all objects have constant albedo color
     
}
