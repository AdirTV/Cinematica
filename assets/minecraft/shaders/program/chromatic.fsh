#version 150

uniform sampler2D DiffuseSampler;

in vec2 texCoord;  // Replaced 'varying' with 'in'
in vec2 oneTexel;  // Replaced 'varying' with 'in'

out vec4 fragColor;  // Added custom output variable

void main() {
    float dist = pow(length(distance(texCoord.x, 0.5)), 2.5) * 16.0;

    vec4 rValue = texture(DiffuseSampler, texCoord + vec2(oneTexel.x * dist, 0.0));  // Replaced 'texture2D' with 'texture'
    vec4 gValue = texture(DiffuseSampler, texCoord);                                 // Replaced 'texture2D' with 'texture'
    vec4 bValue = texture(DiffuseSampler, texCoord - vec2(oneTexel.x * dist, 0.0)); // Replaced 'texture2D' with 'texture'

    fragColor = vec4(rValue.r, gValue.g, bValue.b, 1.0);  // Replaced 'gl_FragColor' with 'fragColor'
}