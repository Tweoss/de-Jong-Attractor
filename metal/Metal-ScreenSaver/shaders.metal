//
//  shaders.metal
//  Metal-ScreenSaver
//
//  Created by Antoine FEUERSTEIN on 2/19/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

#include <Metal_stdlib>
using namespace metal;

#define AVERAGE_POINT_COUNT pow(2.0, 17.0)

struct ColoredPoint {
    float2 coord;
    float3 color;
};

static float3 cubehelix(float x, float y, float z) {
    float a = y * z * (1.0 - z);
    float c = cos(x + M_PI_F / 2.0);
    float s = sin(x + M_PI_F / 2.0);
    return float3(
                  z + a * (1.78277 * s - 0.14861 * c),
                  z - a * (0.29227 * c + 0.90649 * s),
                  z + a * (1.97294 * c)
                  );
}


static float3 rainbow(float t) {
    float t_prime = t;
    if (t < 0.0 || t > 1.0) {
        t_prime -= floor(t);
    };
    float ts = abs(t - 0.5);
    return cubehelix(
                     (360.0 * t - 100.0) / 180.0 * M_PI_F,
                     1.5 - 1.5 * ts,
                     0.8 - 0.9 * ts
                     );
}

static ColoredPoint transformPoint(uint2 p, float a, float b, float c, float d, uint width, uint height) {
    float x1 = p[0];
    float y1 = p[1];
    float x2 = x1;
    float y2 = y1;
    for (int i = 0; i < 10; i ++) {
        x1 = x2; y1 = y2;
        x2 = sin(a * y1) - cos(b * x1);
        y2 = sin(c * x1) - cos(d * y1);
    }
    float v_t = atan(float(p[1] * 2 / height - 1 ) / float(p[0] * 2 / width - 1)) / M_PI_F;
    float3 rgb = rainbow(v_t / 4.0 + 0.25);
    float2 coord = float2(x2 / 2.0, y2 / 2.0);
    return ColoredPoint {coord, rgb};
}

static float cheap_sine(float num) {
    float num_modded = fmod(num, M_PI_F * 2);
    return num_modded - pow(num_modded, 3.0) / 6 + pow(num_modded, 5) / 120 - pow(num_modded, 7) / 5040;
}

kernel void compute_function(texture2d<float, access::write> texture [[texture(0)]], uint2 gid [[thread_position_in_grid]], device const float &time [[buffer(0)]]) {
    texture.write(float4(0.0, 0.0, 0.0, 0.0), gid);
    if (
        ((gid.x * gid.y + 201 * gid.x + 101 * gid.y) % 1000) / 1000.0
        <
        AVERAGE_POINT_COUNT / (texture.get_height() * texture.get_width())
        ) {
            float a = -2.0 + cheap_sine( time );
            float b = -2.0 + cheap_sine(time / 120);
            float c = -1.2 + cheap_sine(time / 360);
            float d =  2.0;
            ColoredPoint color_point = transformPoint(gid, a, b, c, d, texture.get_width(), texture.get_height());
            
            float opacity = 1.0;
            uint x = color_point.coord[0] / 3 * texture.get_width() + texture.get_width() / 2;
            uint y = color_point.coord[1] / 3 * texture.get_height() + texture.get_height() / 2;
            texture.write(float4(color_point.color, opacity), uint2(x,y));
        }
}
