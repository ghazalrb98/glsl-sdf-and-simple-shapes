
varying vec2 vUvs;
uniform vec2 resolution;
uniform float time;

vec3 YELLOW = vec3(1.0, 1.0, 0.25);
vec3 BLUE = vec3(0.25, 0.25, 1.0);
vec3 RED = vec3(1.0, 0.25, 0.25);
vec3 GREEN = vec3(0.25, 1.0, 0.25);
vec3 PURPLE = vec3(1.0, 0.25, 1.0);

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

vec3 BackgroundColor() {
  float distFromCenter = length(vUvs - 0.5);
  float vigenette = 1.0 - distFromCenter;
  vigenette = smoothstep(0.0, 0.7, vigenette);
  vigenette = remap(vigenette, 0.0, 1.0, 0.3, 1.0);

  return vec3(vigenette);
}

vec3 drawGrid(vec3 color, vec3 lineColor, float cellSpacing, float lineWidth) {
  vec2 center = vUvs - 0.5;
  vec2 cell = abs(fract(center * resolution / vec2(cellSpacing)) - 0.5);
  float distToEdge = (0.5 - max(cell.x, cell.y)) * cellSpacing;
  float lines = smoothstep(0.0, lineWidth, distToEdge);    
  // lineWidth is the point where we decide to stop the line and choose the bg color

  color = mix(lineColor, color, lines);
  return color;
}

float sdfCircle(vec2 p, float r) {
  return length(p) - r;
}

float sdfLine(vec2 p, vec2 a, vec2 b)
{
  vec2 pa = p - a;
  vec2 ba = b - a;
  float t = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);   
  // we use clamp cause it's a line segment not an infinite line
  // if the perpendicular foot falls outside, we choose the nearest endpoint.

  return length(pa - ba * t);
}

void main() {
  vec2 pixelCoords = (vUvs - 0.5) * resolution;
  
  vec3 color = BackgroundColor();
  color = drawGrid(color, vec3(0.5), 10.0, 1.0);
  color = drawGrid(color, vec3(0.0), 100.0, 2.0);

  float d = sdfCircle(pixelCoords, 100.0);
  // color = mix(RED, color, step(0.0, d));

  float d2 = sdfLine(pixelCoords, vec2(-100.0, -50.0), vec2(-75.0, 100.0));
  color = mix(RED, color, step(5.0, d2));

  gl_FragColor = vec4(color, 1.0);
}