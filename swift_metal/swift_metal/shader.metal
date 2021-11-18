//
//  shader.metal
//  swift_metal
//
//  Created by Francis Chua on 11/15/21.
//

#include <metal_stdlib>
using namespace metal;

#define AVERAGE_POINT_COUNT pow(2.0, 17.0)

struct Point {
    float2 coord;
};


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
    float2 coord = float2(x2 / 2.0, y2 / 2.0);
    float hue = atan_expanded(p_y, p_x) / 2 / M_PI_F;// +  fmod(time, 2 ) / 2 + 0.5;
    return ColoredPoint {coord, hsv_to_rgb(float3(hue, 1.0, 1.0))};
}

unsigned int hash(unsigned int x) {
    x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = (x >> 16) ^ x;
    return x;
}

kernel void compute_function(texture2d<float, access::write> texture [[texture(0)]], uint2 gid [[thread_position_in_grid]], device const float &time [[buffer(0)]], device const float &a [[buffer(1)]], device const float &b [[buffer(2)]], device const float &c [[buffer(3)]], device const float &d [[buffer(4)]]) {
    texture.write(float4(0.0, 0.0, 0.0, 0.0), gid);
    
    if (
        float(hash(hash(gid.x) ^ gid.y >> 1)) / float(UINT_MAX)
        <
        AVERAGE_POINT_COUNT / (texture.get_height() * texture.get_width())
        ) {
            
            ColoredPoint color_point = transformPoint(float(gid.x), float(gid.y), a, b, c, d, texture.get_width(), texture.get_height(), time);
            
            float opacity = 1.0;
            uint x = color_point.coord[0] / 3 * texture.get_width() + texture.get_width() / 2;
            uint y = color_point.coord[1] / 3 * texture.get_height() + texture.get_height() / 2;
            texture.write(float4(color_point.color, opacity), uint2(x,y));
        }
}




// Metal side
struct Vertex {
    float2 position;
    float3 color;
};

kernel void transform_function(
                               texture2d<float, access::write> texture [[texture(0)]],
                               device Point *buffer [[ buffer(0) ]],
                               uint2 vid [[ thread_position_in_grid ]],
                               device const float &time [[buffer(1)]], device const float &a [[buffer(2)]], device const float &b [[buffer(3)]], device const float &c [[buffer(4)]], device const float &d [[buffer(5)]]
                               )
{
    
    ColoredPoint color_point = transformPoint(buffer[vid.x].coord.x, buffer[vid.x].coord.y, a, b, c, d, texture.get_width(), texture.get_height(), time);
    float opacity = 1.0;
    uint x = color_point.coord[0] / 3 * texture.get_width() + texture.get_width() / 2;
    uint y = color_point.coord[1] / 3 * texture.get_height() + texture.get_height() / 2;
    texture.write(float4(color_point.color, opacity), uint2(x,y));
    buffer[vid.x].coord = color_point.coord;
}

kernel void fill_black(
                               texture2d<float, access::write> texture [[texture(0)]]
                       , uint2 gid [[thread_position_in_grid]]
                               )
{
    
    texture.write(float4(0.0, 0.0, 0.0, 0.0), gid);
}



