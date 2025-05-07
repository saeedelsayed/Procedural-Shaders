// ==========================================
// Shader: Circle Shader
// Category: Geometry
// Description: Draws a simple filled circle.
// Screenshot: screenshots/geometry/circle.png
// ==========================================

// Converts RGB values from 0–255 range to normalized 0–1 range (GLSL expects 0–1)
vec3 rgb(float r, float g, float b) {
    return vec3(r / 255.0, g / 255.0, b / 255.0);
}

/**
 * Draws a circle centered at `pos`, with radius `rad` and color `color`.
 * `uv` is the current pixel position. The function returns a vec4 color,
 * where alpha represents how close the pixel is to the circle edge (for blending).
 */
vec4 circle(vec2 uv, vec2 pos, float rad, vec3 color) {
    // Compute the distance from current pixel (uv) to the circle center (pos), minus radius
    float d = length(pos - uv) - rad;

    // Clamp the distance to the range [0,1] to use for alpha blending
    // Clamp function limits a value to stay within a certain range.
    float t = clamp(d, 0.0, 1.0);

    // Return the final color with alpha = 1.0 - t, making center fully opaque and edge transparent
    return vec4(color, 1.0 - t);
}


// The main shader function, executed per-pixel (fragment)
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Store pixel coordinates (uv) in screen space
    vec2 uv = fragCoord.xy;
    // Compute center of screen using iResolution (width, height of render target)
    vec2 center = iResolution.xy * 0.5;
    // Define circle radius as 25% of screen height
    float radius = 0.25 * iResolution.y;
    // Set background layer color using normalized RGB (light bluish-gray)
    vec4 layer1 = vec4(rgb(210.0, 222.0, 228.0), 1.0);
    // Define the color for the circle (reddish-orange)
    vec3 red = rgb(225.0, 95.0, 60.0);
    // Create a colored circle layer at the screen center
    vec4 layer2 = circle(uv, center, radius, red);
   // Blend circle layer over background using the circle's alpha (anti-aliased edge)
    fragColor = mix(layer1, layer2, layer2.a);
}


// ==========================================
// Shader: Square Shader
// Category: Geometry
// Description: Draws a centered red square using an SDF approach.
// Screenshot: screenshots/geometry/square.png
// ==========================================
vec3 sdfSquare(vec2 uv, float size, vec2 offset) {
  float x = uv.x - offset.x;
  float y = uv.y - offset.y;
  float d = max(abs(x), abs(y)) - size;

  return d > 0. ? vec3(1.) : vec3(1., 0., 0.);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = fragCoord/iResolution.xy; // <0, 1>
  uv -= 0.5; // <-0.5,0.5>
  uv.x *= iResolution.x/iResolution.y; // fix aspect ratio

  vec2 offset = vec2(0.0, 0.0);

  vec3 col = sdfSquare(uv, 0.2, offset);

  // Output to screen
  fragColor = vec4(col,1.0);
}

// ==========================================
// Shader: SDF Sphere Raymarch Shader
// Category: Geometry
// Description: 
//   Provides geometric primitives and operations for raymarching-based rendering.
//   Implements a scene defined by a signed distance field (a sphere), normal 
//   estimation via central differences, and raymarching to detect surface hits.
// ==========================================

/**
 * Function: scene
 * Description: Defines the distance field of the scene. In this case, a single sphere.
 * Input:
 *   - position (vec3): The point in space to evaluate.
 * Output:
 *   - float: Signed distance from the point to the closest surface.
 */
float scene(vec3 position) {
    float radius = 0.3;
    return length(position) - radius;
}

/**
 * Function: getNormal
 * Description: Approximates the surface normal at a point using central differences.
 * Input:
 *   - pos (vec3): Surface point where the normal is evaluated.
 *   - smoothness (float): Step size for the numerical gradient.
 * Output:
 *   - vec3: Estimated normal vector at the given point.
 */
vec3 getNormal(vec3 pos, float smoothness) {
    vec3 n;
    vec2 dn = vec2(smoothness, 0.0);
    n.x = scene(pos + dn.xyy) - scene(pos - dn.xyy);
    n.y = scene(pos + dn.yxy) - scene(pos - dn.yxy);
    n.z = scene(pos + dn.yyx) - scene(pos - dn.yyx);
    return normalize(n);
}

/**
 * Function: raymarch
 * Description: Performs sphere tracing to find the intersection with the scene.
 * Input:
 *   - position (vec3): Ray origin.
 *   - direction (vec3): Ray direction (normalized).
 * Output:
 *   - float: Distance to the first intersection; -1.0 if no hit.
 */
float raymarch(vec3 position, vec3 direction) {
    float total_distance = 0.0;
    for (int i = 0; i < 32; ++i) {
        float d = scene(position + direction * total_distance);
        if (d < 0.005) {
            return total_distance;
        }
        total_distance += d;
    }
    return -1.0;
}
