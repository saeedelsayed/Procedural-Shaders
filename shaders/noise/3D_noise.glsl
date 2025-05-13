// ==========================================
// 3D Noise Function
// Category: Noise
// Description: 3D noise is generated through various techniques and serves as the foundation for numerous applications, 
//              such as volumetric cloud rendering, terrain generation, and procedural texture creation.
// ==========================================

uniform sampler3D texture3DInput;
uniform sampler2D texture2DInput;

// ------------------------------------------
// Input: vec3 x: The position of the point for noise calculation.
//        sampler3D texture3DInput
// Output: A float representing the noise value at the given point, ranging from -1.0 to 1.0.
// Description: Directly sample data from a 3D texture and perform smooth interpolation 
//              to generate noise that satisfies LOD requirements.
// 32.0 matching to the resolution
// ------------------------------------------
float texture3DInterNoise(in vec3 x, sampler3D texture3DInput)
{
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);

    x = p + f;
    return textureLod(texture3DInput, (x + 0.5) / 32.0, 0.0).x * 2.0 - 1.0;
}

// ------------------------------------------
// Input: vec3 x: The position of the point for noise calculation.
//        sampler2D texture2DInput
// Output: A float representing the noise value at the given point, ranging from -1.0 to 1.0.
// Description: Compute noise at a given point by sampling from a 2D texture.
//              By using the constants 37.0 and 239.0, the influence of the z coordinate 
//              is applied to the x and y directions, creating different texture offsets, 
//              ensuring the mapping of 3D coordinates into the 2D texture space.
// 256.0 matching to the resolution
// ------------------------------------------
float dis3DSampling2DNoise(in vec3 x, sampler2D texture2DInput)
{
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    vec2 uv = (p.xy + vec2(37.0, 239.0) * p.z) + f.xy;
    vec2 rg = textureLod(texture2DInput, (uv + 0.5) / 256.0, 0.0).yx;
    return mix(rg.x, rg.y, f.z) * 2.0 - 1.0;
}

// ------------------------------------------
// Input: vec3 x: The position of the point for noise calculation.
//        sampler3D texture2DInput
// Output: A float representing the noise value at the given point, ranging from -1.0 to 1.0.
// Description: Generates noise by sampling a 2D texture.
//              Fetch texel data from the texture, and performs bilinear interpolation 
//              between the adjacent texels to calculate the noise value at the given point.
// 255 matching to the resolution
// ------------------------------------------
float sample3Dfrom2DNoise(in vec3 x, sampler2D texture2DInput)
{
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    ivec3 q = ivec3(p);
    ivec2 uv = q.xy + ivec2(37, 239) * q.z;
    vec2 rg = mix(mix(texelFetch(texture2DInput, (uv) & 255, 0),
                      texelFetch(texture2DInput, (uv + ivec2(1, 0)) & 255, 0), 
                      f.x),
                  mix(texelFetch(texture2DInput, (uv + ivec2(0, 1)) & 255, 0),
                      texelFetch(texture2DInput, (uv + ivec2(1, 1)) & 255, 0), 
                      f.x), 
                  f.y).yx;
    return mix(rg.x, rg.y, f.z) * 2.0 - 1.0;  
}
