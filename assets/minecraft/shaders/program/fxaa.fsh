#version 110

uniform sampler2D DiffuseSampler;

varying vec2 texCoord;
varying vec2 oneTexel;

const float fxaa_span_max = 16.0;
const float fxaa_reduce_mul = 0.03125;
const float fxaa_reduce_min = 0.0078125;

vec3 fxaa() {
	vec3 rgbNW = texture2D( DiffuseSampler, texCoord + ( vec2( +0.0, +1.0 ) * oneTexel ) ).rgb;
	vec3 rgbNE = texture2D( DiffuseSampler, texCoord + ( vec2( +1.0, +0.0 ) * oneTexel ) ).rgb;
	vec3 rgbSW = texture2D( DiffuseSampler, texCoord + ( vec2( -1.0, +0.0 ) * oneTexel ) ).rgb;
	vec3 rgbSE = texture2D( DiffuseSampler, texCoord + ( vec2( +0.0, -1.0 ) * oneTexel ) ).rgb;
	vec3 rgbM  = texture2D( DiffuseSampler, texCoord ).rgb;

	const vec3 luma = vec3( 0.299, 0.587, 0.114 );
	float lumaNW = dot( rgbNW, luma );
	float lumaNE = dot( rgbNE, luma );
	float lumaSW = dot( rgbSW, luma );
	float lumaSE = dot( rgbSE, luma );
	float lumaM  = dot( rgbM, luma );

	float lumaMin = min( lumaM, min( min( lumaNW, lumaNE ), min( lumaSW, lumaSE ) ) );
	float lumaMax = max( lumaM, max( max( lumaNW, lumaNE ), max( lumaSW, lumaSE ) ) );

	vec2 dir;
	dir.x = -( ( lumaNW + lumaNE ) - ( lumaSW + lumaSE ) );
	dir.y =  ( ( lumaNW + lumaSW ) - ( lumaNE + lumaSE ) );

	float dirReduce = max( ( lumaNW + lumaNE + lumaSW + lumaSE ) * fxaa_reduce_mul, fxaa_reduce_min );

	float rcpDirMin = 1.0 / ( min( abs( dir.x ), abs( dir.y ) ) + dirReduce );

	dir = min( vec2( fxaa_span_max,  fxaa_span_max ),
	max( vec2( -fxaa_span_max, -fxaa_span_max ), dir * rcpDirMin ) ) * oneTexel;

	vec2 dir2 = dir * 0.5;
	vec3 rgbA = 0.5 * ( texture2D( DiffuseSampler, texCoord.xy + ( dir * -0.23333333 ) ).xyz + texture2D( DiffuseSampler, texCoord.xy + ( dir * 0.16666666 ) ).xyz);
	vec3 rgbB = ( rgbA * 0.5 ) + ( 0.25 * ( texture2D( DiffuseSampler, texCoord.xy - dir2 ).xyz + texture2D( DiffuseSampler, texCoord.xy + dir2 ).xyz ) );
	float lumaB = dot( rgbB, luma );

	if ( ( lumaB < lumaMin ) || ( lumaB > lumaMax ) ) {
		return rgbA;
	}

	return rgbB;
}

void main() {
  float dist = 1.0 - pow( length( distance( texCoord, vec2( 0.5, 0.5 ) ) ), 2.0 );
  gl_FragColor = vec4( fxaa() * dist, 1.0 );
}
