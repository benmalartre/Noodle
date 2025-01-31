#version 120

varying vec2 texCoords;

uniform sampler2D position_map;
uniform sampler2D normal_map;
uniform sampler2D color_map;
uniform sampler2D ssao_map;

struct Light {
    vec3 position;
    vec3 color;
    
    float linear;
    float quadratic;
};

const int MAX_NR_LIGHTS = 64;
uniform Light lights[MAX_NR_LIGHTS];
uniform int nb_lights;

uniform mat4 view;

mat4 extractRotationMatrix(mat4 m){
return mat4(m[0].xyzw,
			m[1].xyzw,
			m[2].xyzw,
			0.0,0.0,0.0,1.0);
}

void main()
{      
 
    // Retrieve data from gbuffer
    vec3 fragPos = texture2D(position_map, texCoords).rgb;
    vec3 normal = texture2D(normal_map, texCoords).rgb;
    vec3 diffuse = texture2D(color_map, texCoords).rgb;
    float specular = texture2D(color_map, texCoords).a;
	float ao = texture2D(ssao_map, texCoords).r;
	
	vec3 viewPos = view[3].xyz;
	
    // Then calculate lighting as usual
	vec3 ambient = vec3(0.1 * ao);
    vec3 lighting  = ambient; // hard-coded ambient component
	mat4 rot = extractRotationMatrix(view);
	normal = (rot * vec4(normal,0.0)).xyz;
    vec3 viewDir  = normalize(-fragPos); // Viewpos is (0.0.0)
	//vec3 viewDir  = normalize(viewPos - fragPos);
    for(int i = 0; i < nb_lights; ++i)
    {
        // Diffuse
		vec3 lightPos = (view * vec4(lights[i].position,1.0)).xyz;
        //vec3 lightDir = normalize(lights[i].position - fragPos);
		vec3 lightDir = normalize(lightPos - fragPos);
		lightDir = (rot * vec4(lightDir,1.0)).xyz;
        vec3 diffuse = max(dot(normal, lightDir), 0.0) * diffuse * lights[i].color;
        // Specular
        vec3 halfwayDir = normalize(lightDir + viewDir);  
        float spec = pow(max(dot(normal, halfwayDir), 0.0), 16.0);
        vec3 specular = lights[i].color * spec * specular;
        // Attenuation
        //float distance = length(lights[i].position - fragPos);
		float distance = length(lightPos - fragPos);
        float attenuation = 1.0 / (1.0 + lights[i].linear * distance + lights[i].quadratic * distance * distance);
        diffuse *= attenuation;
        specular *= attenuation;
        lighting += diffuse + specular;
    }    
    gl_FragColor = vec4(lighting, 1.0);


}