#version 330 core
layout (location = 0) in vec3 position;
layout (location = 1) in vec3 normal;

out vec3 vertex_normal;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

void main()
{
    gl_Position = projection * view * model * vec4(position, 1.0); 
    mat3 normal_matrix = mat3(transpose(inverse(view * model)));
    vertex_normal = normalize(vec3(projection * vec4(normal_matrix * normal, 0.0)));
}