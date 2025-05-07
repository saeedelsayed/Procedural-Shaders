// ==========================================
// Shader: SDF Sphere Raymarch Shader
// Category: Example
// Description: 
//   Implements a raymarching renderer using a Signed Distance Field (SDF)
//   for a single sphere. Features include dynamic camera, procedural shading,
//   rim lighting, reflection, refraction, glow, and a star overlay.
// Screenshot: Procedural-Shaders/screenshots/example/example1.png
// ==========================================

const float PI = 3.14159265359;


// Function: scene
// Defines the distance field of the scene. In this case, a single sphere.
float scene(vec3 position) {
    float radius = 0.3;
    return length(position) - radius;
}

// Function: getNormal
// Approximates the surface normal at a point using central differences.
vec3 getNormal(vec3 pos, float smoothness) {
    vec3 n;
    vec2 dn = vec2(smoothness, 0.0);
    n.x = scene(pos + dn.xyy) - scene(pos - dn.xyy);
    n.y = scene(pos + dn.yxy) - scene(pos - dn.yxy);
    n.z = scene(pos + dn.yyx) - scene(pos - dn.yyx);
    return normalize(n);
}

// Function: raymarch
// Performs sphere tracing to find the intersection with the scene.
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

// Look-At Camera Matrix
mat3 calcLookAtMatrix(vec3 ro, vec3 ta, float roll) {
    vec3 forward = normalize(ta - ro);
    vec3 right = normalize(cross(forward, vec3(sin(roll), cos(roll), 0.0)));
    vec3 up = normalize(cross(right, forward));
    return mat3(right, up, forward);
}

// Material Color
// Returns the base surface color modulated by background texture (refraction).
vec4 computeMaterialColor(vec3 dir, vec3 N) {
    vec3 refr = refract(dir, N, 0.7);
    vec2 uv_refr = refr.xy * 0.5 + 0.5;
    vec4 baseColor = vec4(1.0, 0.8, 0.0, 1.0) * 0.75;
    return texture(iChannel1, uv_refr) * baseColor;
}

// Lighting Effects
// Computes rim lighting and reflection contributions.
vec4 computeLighting(vec3 dir, vec3 N) {
    vec3 ref = reflect(dir, N);
    vec2 uv_ref = ref.xy * 0.5 + 0.5;

    float rim = max(0.0, 0.7 + dot(N, dir));
    vec4 rimColor = vec4(rim, rim * 0.5, 0.0, 1.0);
    vec4 reflection = texture(iChannel1, uv_ref) * 0.3;

    return rimColor + reflection;
}

// Procedural Overlay Effects
// Adds stylized glow and star shape over the center.
vec4 computeNoiseOverlay(vec2 uv) {
    float P = PI / 5.0;
    float starVal = (1.0 / P) * (P - abs(mod(atan(uv.x, uv.y) + PI, 2.0 * P) - P));
    vec4 starColor = (distance(uv, vec2(0.0)) < 0.06 - (starVal * 0.03))
        ? vec4(2.8, 1.0, 0.0, 1.0)
        : vec4(0.0);

    float glowFactor = max(0.0, 1.0 - distance(uv * 4.0, vec2(0.0)));
    vec4 glow = vec4(0.6, 0.2, 0.0, 1.0) * glowFactor * 4.0 * (0.2 + abs(sin(iTime)) * 0.8);

    return glow + starColor;
}


// Module: Surface material
// Final Composition of surface
// Material color+ lighting+ procedural overlays 
vec4 computeMaterial(vec3 dir, vec3 N, vec3 pos, vec2 uv) {
    vec4 materialColor = computeMaterialColor(dir, N);
    vec4 lighting = computeLighting(dir, N);
    vec4 overlay = computeNoiseOverlay(uv);
    return materialColor + lighting + overlay;
}


// Main Entry Point
// Main fragment shader function as per ShaderToy conventions.
// Sets up camera, performs raymarching, and assigns final pixel color output.
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.y;
    uv -= vec2(0.5 * iResolution.x / iResolution.y, 0.5);
    uv.y *= -1.0;

    vec3 origin = vec3(sin(iTime * 0.1) * 2.5, 0.0, cos(iTime * 0.1) * 2.5);
    mat3 camMat = calcLookAtMatrix(origin, vec3(0.0), 0.0);
    vec3 direction = normalize(camMat * vec3(uv, 2.5));

    float dist = raymarch(origin, direction);
    if (dist < 0.0) {
        vec2 bgUV = direction.xy * 0.5 + 0.5;
        fragColor = texture(iChannel1, bgUV);
        return;
    }

    vec3 hitPos = origin + direction * dist;
    vec3 normal = getNormal(hitPos, 0.01);

    fragColor = computeMaterial(direction, normal, hitPos, uv);
}
