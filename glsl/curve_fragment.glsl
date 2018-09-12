#version 330 core
in FragData {
	vec3 position;
	vec3 color;
	vec3 normal;
} inData;

out vec4 color;
void main() {
	vec3 lightPos = vec3(0.0);
	vec3 lightColor = vec3(1.0);
	float shininess = 4.0;
	float ka = 0.3;
	float kd = 0.7;
	float ks = 1.0;
	// ambient
	vec3 ambient = ka * lightColor;
	// diffuse
	vec3 lightDir = normalize(lightPos - inData.position);
	vec3 diffuse = max(dot(inData.normal, lightDir), 0.0) * kd * lightColor;
	// specular
	vec3 reflectDir = reflect(-lightDir, inData.normal);
	vec3 specular = pow(max(dot(lightDir, reflectDir), 0.0), shininess) * ks * lightColor;
	// final color
	color = vec4((ambient + diffuse + specular) * inData.color, 1.0);
};