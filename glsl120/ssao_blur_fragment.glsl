#version 120
varying vec2 texCoords;

uniform sampler2D ssao_map;
uniform vec2 texture_size;

void main() {
    vec2 texelSize = 1.0 / texture_size;
    float result = 0.0;
    for (int x = -2; x < 2; ++x) 
    {
        for (int y = -2; y < 2; ++y) 
        {
            vec2 offset = vec2(float(x), float(y)) * texelSize;
            result += texture2D(ssao_map, texCoords + offset).r;
        }
    }
    float v = result / (4.0 * 4.0);
    gl_FragColor = vec4(v,v,v,1.0);
}  