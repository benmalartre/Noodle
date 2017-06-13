#version 120

varying vec3 pos_eye;
varying vec3 n_eye;
uniform samplerCube cube_texture;
uniform mat4 view; // view matrix
uniform mat4 inverseView;

void main () {
  /* reflect ray around normal from eye to surface */
  vec3 incident_eye = normalize (pos_eye);
  vec3 normal = normalize (n_eye);

  vec3 reflected = reflect (incident_eye, normal);
  // convert from eye to world space
  reflected = vec3 (inverseView * vec4 (reflected, 0.0));

  gl_FragColor = textureCube(cube_texture, reflected);
}