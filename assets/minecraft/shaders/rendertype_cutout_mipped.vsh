#version 150 core
in vec3 Position;
in vec2 UV0;
in vec4 Color;
out vec2 vUV0;
out vec4 vColor;
uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
void main() {
    vUV0 = UV0;
    vColor = Color;
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
}
