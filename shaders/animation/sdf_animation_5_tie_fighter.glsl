/*
============================================================
  Example: Type 5 – Predefined Path Animation (TIE Fighter)
============================================================

This shader demonstrates how to use the animation module's
type 5 animation (Predefined Path) to animate an SDF sphere
along a TIE Fighter-inspired trajectory over time.

- Uses `tiePos()` from animation module
- Applies `animateSDF_TIEPath(...)` to modify sphere position
- Renders the animated SDF with simple raymarching

Screnshots: screenshots/animation/tie_fighter_trajectory.fig
*/

// === SDF struct ===
struct SDF {
    int type;
    vec3 position;
    vec3 size;
    float radius;
};

// === From animation module ===
vec3 tiePos(vec3 p, float t) {
    float x = cos(t * 0.7);
    p += vec3(
        x,
        cos(t),
        sin(t * 1.1)
    );
    p.xy *= mat2(
        cos(-x * 0.1), sin(-x * 0.1),
       -sin(-x * 0.1), cos(-x * 0.1)
    );
    return p;
}

// === Module function ===
SDF animateSDF_TIEPath(SDF sdf, float t, vec3 param) {
    sdf.position = tiePos(sdf.position, t);
    return sdf;
}

// === Basic sphere SDF ===
float sdf_sphere(vec3 p, float r) {
    return length(p) - r;
}

// === Main rendering ===
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;

    vec3 ro = vec3(0.0, 0.0, -5.0);  // Camera origin
    vec3 rd = normalize(vec3(uv, 1.5)); // Ray direction

    // Initial SDF definition
    SDF sdf;
    sdf.type = 0;
    sdf.position = vec3(0.0, 0.0, 3.0);
    sdf.size = vec3(0.5);
    sdf.radius = 0.5;

    // Animate using module
    sdf = animateSDF_TIEPath(sdf, iTime, vec3(0.0)); // param unused

    // Raymarching
    float t = 0.0;
    vec3 p;
    float dist;
    bool hit = false;

    for (int i = 0; i < 100; ++i) {
        p = ro + t * rd;
        dist = sdf_sphere(p - sdf.position, sdf.radius);
        if (dist < 0.01) {
            hit = true;
            break;
        }
        t += dist;
        if (t > 20.0) break;
    }

    vec3 col = hit ? vec3(0.3, 1.0, 0.6) : vec3(0.0);
    fragColor = vec4(col, 1.0);
}
