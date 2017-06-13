#version 120

attribute vec3 position; // positions from mesh
attribute vec3 normal; // normals from mesh
uniform mat4 projection, view, model; // proj, view, model matrices
varying vec3 pos_eye;
varying vec3 n_eye;

void main () {
  pos_eye = vec3 (view * model * vec4 (position, 1.0));
  n_eye = vec3 (view * model * vec4 (normal, 0.0));
  gl_Position = projection * view * model * vec4 (position, 1.0);
}