//
//  shader.metal
//  swift_metal
//
//  Created by Francis Chua on 11/15/21.
//

#include <metal_stdlib>
using namespace metal;

#define AVERAGE_POINT_COUNT pow(2.0, 18.0)


struct ColoredPoint {
    float2 coord;
    float3 color;
};

float3 hsv_to_rgb(float3 hsv) {
    float r = 0;
    float g = 0;
    float b = 0;
    float h = hsv[0], s = hsv[1], v = hsv[2];
    
    int i = floor(h * 6);
    float f = h * 6 - i;
    float p = v * (1 - s);
    float q = v * (1 - f * s);
    float t = v * (1 - (1 - f) * s);
    switch (i % 6) {
        case 0: r = v, g = t, b = p; break;
        case 1: r = q, g = v, b = p; break;
        case 2: r = p, g = v, b = t; break;
        case 3: r = p, g = q, b = v; break;
        case 4: r = t, g = p, b = v; break;
        case 5: r = v, g = p, b = q; break;
    }
    
    return float3(r,g,b);
}

float atan_expanded(float y, float x) {
    if (x > 0) {
        return atan(y / x);
    } else if (y > 0) {
        return M_PI_2_F - atan(x / y);
    } else if (y < 0) {
        return -M_PI_2_F - atan(x / y);
    } else if (x < 0) {
        return atan(y / x) + M_PI_F;
    } else {
        return NAN;
    }
}


float3 cubehelix(float x, float y, float z) {
  float a = y * z * (1.0 - z);
  float c = cos(x + M_PI_F / 2.0);
  float s = sin(x + M_PI_F / 2.0);
  return float3(
    z + a * (1.78277 * s - 0.14861 * c),
    z - a * (0.29227 * c + 0.90649 * s),
    z + a * (1.97294 * c)
  );
}

float3 rainbow(float t) {
  if (t < 0.0 || t > 1.0) t -= floor(t);
  float ts = abs(t - 0.5);
  return cubehelix(
    (360.0 * t - 100.0) / 180.0 * M_PI_F,
    1.5 - 1.5 * ts,
    0.8 - 0.9 * ts
  );
}

static ColoredPoint transformPoint(float p_x, float p_y, float a, float b, float c, float d, float width, float height, float time) {
    float x1 = p_x;
    float y1 = p_y;
    float x2 = x1;
    float y2 = y1;
    for (int i = 0; i < 8; i ++) {
        x1 = x2; y1 = y2;
        x2 = sin(a * y1) - cos(b * x1);
        y2 = sin(c * x1) - cos(d * y1);
    }
    float2 coord = float2(x2 / 5 * width + width / 2,  y2 / 5 * height + height / 2);
    float v_t = atan2(p_y, p_x) / M_PI_F;
    float3 color = rainbow(v_t / 4.0 + 0.0);
    return ColoredPoint {coord, color};
}

unsigned int hash(unsigned int x) {
    x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = (x >> 16) ^ x;
    return x;
}

kernel void transform_function(
                               texture2d<float, access::write> texture [[texture(0)]],
                               uint2 gid [[ thread_position_in_grid ]],
                               device const float &time [[buffer(1)]], device const float &a [[buffer(2)]], device const float &b [[buffer(3)]], device const float &c [[buffer(4)]], device const float &d [[buffer(5)]]
                               )
{
    texture.write(float4(0.0, 0.0, 0.0, 0.0), gid);

    if (
            float(hash(hash(gid.x) ^ gid.y >> 1)) / float(UINT_MAX)
            <
            AVERAGE_POINT_COUNT / (texture.get_height() * texture.get_width())
            ) {
                ColoredPoint color_point = transformPoint(gid.x * 2.0 / texture.get_width() - 1.0, gid.y * 2.0 / texture.get_height() - 1.0, a, b, c, d, texture.get_width(), texture.get_height(), time);
                texture.write(float4(color_point.color, 1.0), uint2(color_point.coord));
            }
    
}

