#ifdef GL_ES
precision mediump float;
#endif

uniform mediump float u_time;
uniform mediump vec2 u_resolution;

uniform mediump vec3 u_color1;
uniform mediump vec3 u_color2;

const float pi = 3.14159265358979323846;

/*
Features:
- Sin oscillators (done)
- Square wave oscillator (done)
- RGB controls (done)
- Noise generator (done)
- Triangle oscillator
- Color inversion (done)
- Luma inversion (done)
- Luma keying (done)
*/

float sinOscillator(float c, float freq) {
  return (1.0 + sin(pi / 2.0 + c * freq * pi)) / 2.0;
}

float squareOscillator(float c, float freq) {
  return step(mod(c * freq, 1.0), 0.5);
}

// random function is from Book of Shaders
float random(vec2 st) {
  return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main() {
  // TODO make uniform
  const float brightness = 1.0;
  vec2 p = gl_FragCoord.xy / u_resolution.xy;
  
  vec3 color1 = vec3(1.0, 0.0, 0.0);
  vec3 color2 = vec3(0.0, 0.0, 1.0);
  
  float hFrequency = 2.0;
  float vFrequency = 2.0;
  
  float sinFreqScalar = 4.0;
  float squareFreqScalar = 1.0;
  
  // horizontal sin waves used for luma
  float hSinAmplitude = 1.0;
  float hSin = hSinAmplitude * sinOscillator(p.x, hFrequency * sinFreqScalar);
  
  // vertical sin waves used for chroma keying
  float vSinAmplitude = 1.0;
  float vSin = vSinAmplitude * sinOscillator(p.y, vFrequency * sinFreqScalar);
  
  // horizontal square wave used for color inversion
  float hSquareAmplitude = 1.0;
  float hSquare = hSquareAmplitude * squareOscillator(p.x, hFrequency * squareFreqScalar);
  
  // vertical square wave used for luma inversion
  float vSquareAmplitude = 1.0;
  float vSquare = vSquareAmplitude * squareOscillator(p.y, vFrequency * squareFreqScalar);
  
  // luma is used to mix between colors
  float luma = vSquare - sign(vSquare - 0.5) * brightness * hSin * vSin;
  vec3 color = hSquare - sign(hSquare - 0.5) * mix(color1, color2, luma);
  
  //vec3 color = mix(vec3(luma), color1, vSin);
  //color = mix(vec3(color), color2, hSin);
  
  // the mod in random is because the randomizer does strange things with a large time
  gl_FragColor = vec4(random(p + mod(u_time, 1.0)) * color, 1.0);
}