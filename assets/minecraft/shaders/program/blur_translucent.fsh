#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform sampler2D TranslucentDepthSampler;
uniform sampler2D CloudsDepthSampler;

in vec2 texCoord;  // Input from vertex shader
in vec2 oneTexel;  // Added to handle texture offset (from blobs.vsh)
out vec4 fragColor;  // Custom output variable

#define TAPS 3  // Reduced from 6 to decrease blur radius
#define DISTANCE 3  // Reduced from 6 to decrease blur radius

const float angle = radians(360.0 / float(TAPS));
const float angleSin = sin(angle);
const float angleCos = cos(angle);
const mat2 rotationMatrix = mat2(angleCos, angleSin, -angleSin, angleCos);

vec4 blur() {
    vec2 tapOffset = vec2(0.0, oneTexel.y);  // Use oneTexel for dynamic resolution scaling
    vec4 color = vec4(0.0);
    for (int ii = 0; ii < TAPS; ++ii) {
        for (int jj = 0; jj < DISTANCE; ++jj) {
            color += texture(DiffuseSampler, texCoord + (tapOffset * float(jj + 1)));  // Changed to texture
        }
        tapOffset = rotationMatrix * tapOffset;
    }
    color /= float(TAPS * DISTANCE);
    return color * 0.5;  // Reduced intensity
}

void main() {
    float diffuseDepth = texture(DiffuseDepthSampler, texCoord).r;
    float translucentDepth = texture(TranslucentDepthSampler, texCoord).r;
    float cloudsDepth = texture(CloudsDepthSampler, texCoord).r;
    float blurDepth = min(translucentDepth, cloudsDepth);

    float blurValue = diffuseDepth - blurDepth;
    vec4 color = texture(DiffuseSampler, texCoord);  // Changed to texture

    // Only apply blur to non-cloud translucent elements
    if (blurValue > 0.0 && cloudsDepth != blurDepth) {
        float depth = smoothstep(blurDepth, 1.0, blurDepth + blurValue * 0.25);  // Reduced influence
        color = mix(color, blur(), depth * 0.5);  // Reduced mix strength
    }
    
    fragColor = color;
    gl_FragDepth = diffuseDepth;
}