 #version 330 core
out vec4 outColor;
in vec2 texCoords;

uniform sampler2D position_map;
uniform sampler2D normal_map;
uniform sampler2D color_map;
uniform sampler2D shadow_map;

uniform vec3 camera_position;
uniform mat4 light_view;
uniform mat4 light_proj;
uniform mat4 view_rotation_matrix;
uniform mat4 view;

const float bias2 = 0.001;

// This define the value to move one pixel left or right
uniform float x_pixel_offset;	
// This define the value to move one pixel up or down
uniform float y_pixel_offset ;

struct Sun{
    vec3 direction;
    float intensity;
    vec3 color;
    
};

struct Light {
    vec3 position;
    vec3 color;
    
    float linear;
    float quadratic;
};

const int MAX_NR_LIGHTS = 64;
uniform Light lights[MAX_NR_LIGHTS];
uniform int nb_lights;
uniform Sun sun;

vec3 getShadowCoords(vec3 dir)
{
	mat4 inv_view = inverse(view);
    mat4 projected = light_proj * light_view * inv_view;
	vec4 proj_dir = projected * vec4(dir,1);
	
    proj_dir = proj_dir/proj_dir.w;
	return proj_dir.xyz;
}

float lookup( vec3 coords,vec2 offset)
{
	vec2 textureCoordinates = coords.xy * vec2(0.5,0.5) + vec2(0.5,0.5);

	offset *= vec2(x_pixel_offset,y_pixel_offset);
    const float bias = -0.005;
    float depth_value = texture( shadow_map, textureCoordinates + offset ).r ;
	if(depth_value>=1.0)return 1.0;
	if(coords.z * 0.5 + 0.5 < depth_value-bias)
	return 1.0;
	else return 0.0;
}

mat4 extractRotationMatrix(mat4 m){
return mat4(m[0].xyzw,
			m[1].xyzw,
			m[2].xyzw,
			0.0,0.0,0.0,1.0);
}

void main()
{      
    // Retrieve data from gbuffer
    vec3 position = texture(position_map, texCoords).rgb;
    vec3 normal = texture(normal_map, texCoords).rgb;
    vec3 diffuse = texture(color_map, texCoords).rgb;
    float specular = texture(color_map, texCoords).a;
	
    float ao = texture(shadow_map, texCoords).r;

	
	vec3 viewPos = view[3].xyz;
	
    // Then calculate lighting as usual
	vec3 ambient = vec3(0.5 * ao);
    vec3 lighting  = ambient;
	mat4 rot = extractRotationMatrix(view);
	//normal = (rot * vec4(normal,0.0)).xyz;
	
    vec3 viewDir  = normalize(-position); // Viewpos is (0.0.0)
    vec3 sunDir = sun.direction;
    sunDir = (rot * vec4(sunDir,1.0)).xyz;
	
	lighting = vec3(dot(normal,sunDir));// * sun.color;
    //lighting += max(dot(normal,sunDir),0.0);// * sun.color;
	
    vec3 eye_dir = position - camera_position;

	vec3 shadow_coords = getShadowCoords(eye_dir);
	float s = 0.0;
	
	s =  lookup(shadow_coords,vec2(0.0,0.0));
	
	/*
    for(int i = 0; i < nb_lights; ++i)
    {
        // Diffuse
		vec3 lightPos = (view * vec4(lights[i].position,1.0)).xyz;
        //vec3 lightDir = normalize(lights[i].position - position);
		vec3 lightDir = normalize(lightPos - position);
		lightDir = (rot * vec4(lightDir,1.0)).xyz;
        vec3 diffuse = max(dot(normal, lightDir), 0.0) * diffuse * lights[i].color;
        // Specular
        vec3 halfwayDir = normalize(lightDir + viewDir);  
        float spec = pow(max(dot(normal, halfwayDir), 0.0), 16.0);
        vec3 specular = lights[i].color * spec * specular;
        // Attenuation
	float distance = length(lightPos - position);
        float attenuation = 1.0 / (1.0 + lights[i].linear * distance + lights[i].quadratic * distance * distance);
        diffuse *= attenuation;
        //specular *= attenuation;
        lighting += diffuse;// + specular;
    }    */
    outColor = vec4(diffuse * (s/2.0 + 0.2) * lighting, 1.0);

}

