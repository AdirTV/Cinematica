#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;
uniform sampler2D Sampler0; // to read texture alpha for special blocks

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec3 ChunkOffset;
uniform int FogShape;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec4 normal;

#define PI 3.1415926535897932

void main() {
    vec3 pos = Position + ChunkOffset;

    // --- DISPLACEMENT LOGIC ---
    float alpha = texture(Sampler0, UV0).a * 255.0;

    // Only apply effect to special alpha markers (like leaves or custom blocks)
    if (alpha == 1.0 || alpha == 2.0 || alpha == 253.0) {
        // Gentle wave based on world position
        float waveX = sin((Position.x + Position.y * 0.5) * 0.5 + pos.z * 0.05) * 0.05;
        float waveZ = cos((Position.z + Position.y * 0.5) * 0.5 + pos.x * 0.05) * 0.05;

        // Amplify slightly for alpha 2
        if (alpha == 2.0) {
            waveX *= 1.5;
            waveZ *= 1.5;
        }

        // Apply offset
        pos.x += waveX;
        pos.z += waveZ;
    }

    // --- ORIGINAL DEFAULT LOGIC ---
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);

    vertexDistance = fog_distance(ModelViewMat, pos, FogShape);
    vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
    texCoord0 = UV0;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
}
