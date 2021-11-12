//
//  shaders.metal
//  Metal-ScreenSaver
//
//  Created by Antoine FEUERSTEIN on 2/19/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

#include <Metal_stdlib>
using namespace metal;

#define NUM_PARTICLES 13.0

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



static ColoredPoint transformPoint(uint2 p, float a, float b, float c, float d) {
    float x1 = p[0];
    float y1 = p[1];
    float x2 = x1;
    float y2 = y1;
    for (int i = 0; i < 10; i ++) {
        x1 = x2; y1 = y2;
        x2 = sin(a * y1) - cos(b * x1);
        y2 = sin(c * x1) - cos(d * y1);
    }
    float v_t = atan(float(p[0]) / float(p[1])) / M_PI_F;
    float3 rgb = rainbow(v_t / 4.0 + 0.25);
    float2 coord = float2(x2 / 2.0, y2 / 2.0);
    return ColoredPoint {coord, rgb};
}

//static float3 particles(float2 uv, float3 color, float radius, float offset, float time)
//{
//    //float2 position = float2(sin(offset * (time + 1.0)) * 1, sin(offset * (time + 1.5 * sin(time)))) * (cos(time - sin(offset)) * atan(offset * 1));
//    float2 position = float2(sin(offset * (time + 1.0)), sin(offset * (time + 1.0 * sin(time)))) * (cos(time - sin(offset)) * atan(offset * 1));
//    float dist = radius / distance(uv, position);
//
//    return color * pow(dist, 0.7);
//}

kernel void compute_function(texture2d<float, access::write> texture [[texture(0)]], uint2 gid [[thread_position_in_grid]], device const float &time [[buffer(0)]]) {
//    float2 size = float2(texture.get_width(), texture.get_height());
//    float2 uv = (float2(gid) - (-0.25 * (cos((time + 1.0))) * cos(time * atan(1.0)) + 0.55) * size) / size.y;
//    float3 color = float3(((sin(time * 0.15) + 0.05) * 0.4), ((sin(time * 0.14) + 0.00) * 0.4), ((sin(time * 2.0) + 0.05) * 0.4));
//    float3 pixel = float3(0);
//    float radius = clamp(abs(0.008 * sin(time)), 0.002, 1.0);
//
//    for (float i = 0.0; i < NUM_PARTICLES; i++)
//    {
//        pixel += abs(particles(uv, color, radius, i / NUM_PARTICLES, time));
//    }
    if (sin(float(gid.x * gid.y)) > 0.99999) {
        float a = -2.0 + sin( time );
        float b = -2.0 + sin(time / 120);
        float c = -1.2 + sin(time / 360);
        float d =  2.0;
        ColoredPoint color_point = transformPoint(gid, a, b, c, d);
        float opacity = 1.0;
        uint x = color_point.coord[0] / 3 * texture.get_width() + texture.get_width() / 2;
        uint y = color_point.coord[1] / 3 * texture.get_height() + texture.get_height() / 2;
        texture.write(float4(pow(color_point.color,float3(.75)), opacity), uint2(x,y));
    } else {
        texture.write(float4(0.0, 0.0, 0.0, 1.0), gid);
    }


}
