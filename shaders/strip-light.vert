
{{triadica_perspective}}
{{triadica_noises}}

uniform float u_offset;
uniform float u_dot_radius;

attribute vec3 a_position;
attribute float a_direction;

varying float v_r;
varying float v_s;

const float PI = 3.1415926535897932384626433832795;
const float PI_2 = 1.57079632679489661923;
const float PI_3 = 1.0471975511965976;
const float PI_4 = 0.785398163397448309616;

void main() {
  float angle = PI_3 * a_direction;

  float ax = rand(a_position.xy + a_position.xz);
  float ay = rand(a_position.yx + a_position.yz);

  vec3 p = a_position;
  p += rightward * (ax * u_offset);
  p += upward * (ay * u_offset);

  if (a_direction >= 0.0) {
    vec2 dot_offset = vec2(
      u_dot_radius * cos(angle),
      u_dot_radius * sin(angle)
    );

    p += rightward * dot_offset.x;
    p += upward * dot_offset.y;
  }

  PointResult result = transform_perspective(p);

  vec3 pos_next = result.point;

  v_s = result.s;
  v_r = result.r;
  gl_Position = vec4(pos_next * 0.002, 1.0);
}
