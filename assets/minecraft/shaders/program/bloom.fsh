#version 110

uniform sampler2D DiffuseSampler;

varying vec2 texCoord;

float luminance( vec3 rgb ) {
    return dot( rgb, vec3( 0.2125, 0.7154, 0.0721 ) );
}

#define TAPS_X  ( 32 )
#define TAPS_Y  ( 32 )

float estimate_luminance() {
  float accum = 0.0;
  for (int ii = 0; ii < TAPS_X; ++ii) {
    float xx = float( ii + 1 ) / float( TAPS_X + 1 );
    for (int jj = 0; jj < TAPS_Y; ++jj) {
      float yy = float( jj + 1 ) / float( TAPS_Y + 1 );
      accum += luminance( texture2D( DiffuseSampler, vec2( xx, yy ) ).rgb );
    }
  }
  return accum / float( TAPS_X * TAPS_Y );
}

vec3 rgb2hsv( vec3 c ) {
  vec4 K = vec4( 0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0 );
  vec4 p = mix( vec4( c.bg, K.wz ), vec4( c.gb, K.xy ), step( c.b, c.g ) );
  vec4 q = mix( vec4( p.xyw, c.r ), vec4( c.r, p.yzx ), step( p.x, c.r ) );

  float d = q.x - min( q.w, q.y );
  float e = 1.0e-10;
  return vec3( abs( q.z + ( q.w - q.y ) / ( 6.0 * d + e ) ), d / ( q.x + e ), q.x );
}

vec3 hsv2rgb( vec3 c ) {
  vec4 K = vec4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
  vec3 p = abs( fract( c.xxx + K.xyz ) * 6.0 - K.www );
  return c.z * mix( K.xxx, clamp( p - K.xxx, 0.0, 1.0 ), c.y );
}

#define TAPS 6
#define DISTANCE 6

const float angle = radians( 360.0 / float( TAPS ) );
const float angleSin = sin( angle );
const float angleCos = cos( angle );
const mat2 rotationMatrix = mat2( angleCos, angleSin, -angleSin, angleCos );

vec3 bloom() {
  vec2 tapOffset = vec2( 0.0, 1.0 / 1024.0 ); // Fixed step for varying resolutions
  vec4 color = vec4( 0.0 );
  for ( int ii = 0; ii < TAPS; ++ii ) {
    for ( int jj = 0; jj < DISTANCE; ++jj ) {
      color += texture2D( DiffuseSampler, texCoord + ( tapOffset * float( jj + 1 ) ) );
    }
    tapOffset = rotationMatrix * tapOffset;
  }
  color /= float( TAPS * DISTANCE );
  return color.rgb;
}

void main() {
  vec3 color = texture2D( DiffuseSampler, texCoord ).rgb;

  float screenLuminance = estimate_luminance();

  vec3 hsv = rgb2hsv( color );
  hsv.y = pow( hsv.y, 0.9 );
  hsv.z =  pow( hsv.z, 0.9 );
  color = hsv2rgb( hsv );

  float hdr = pow( luminance( mix( color, vec3( 0.0 ), screenLuminance ) ), 1.25 );
  gl_FragColor = vec4( color + bloom() * hdr, 1.0 );
}
