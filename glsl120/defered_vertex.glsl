#version 120
attribute vec2 position;
attribute vec2 coords;

varying vec2 texCoords;

void main()
{
    gl_Position = vec4(position,0.0f,1.0f);
    texCoords = coords;
}