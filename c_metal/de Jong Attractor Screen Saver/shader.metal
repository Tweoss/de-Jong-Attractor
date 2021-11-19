//
//  shader.metal
//  de Jong Attractor Screen Saver
//
//  Created by Francis Chua on 11/12/21.
//

#include <Metal_stdlib>
using namespace metal;

#define AVERAGE_POINT_COUNT pow(2.0, 18.0)

struct ColoredPoint {
    float2 coord;
    float3 color;
};

static ColoredPoint transformPoint(float p_x, float p_y, float a, float b, float c, float d, float width, float height) {
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
    return ColoredPoint {coord, float3(p_x / width, 0.0, p_y / height)};
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
           
            ColoredPoint color_point = transformPoint(gid.x, gid.y, a, b, c, d, texture.get_width(), texture.get_height());

            float opacity = 1.0;
            uint x = color_point.coord[0] / 3 * texture.get_width() + texture.get_width() / 2;
            uint y = color_point.coord[1] / 3 * texture.get_height() + texture.get_height() / 2;
            texture.write(float4(color_point.color, opacity), uint2(x,y));
        }
}
