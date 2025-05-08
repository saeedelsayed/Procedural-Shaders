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
