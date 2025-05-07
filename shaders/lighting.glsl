// ==========================================
// Module: Rim lighting and reflection Shader
// Category: Lighting
// Description: 
//   Computes rim lighting and reflection contributions.
// ==========================================

/**
 * Function: computeLighting
 * Description: 
 *   Computes reflection and rim lighting contributions based on view direction
 *   and surface normal. Reflection uses environment texture; rim light depends 
 *   on the viewing angle to emphasize edges.
 * Input:
 *   - dir (vec3): View direction from camera to surface.
 *   - N (vec3): Normal vector at the surface point.
 * Output:
 *   - vec4: Combined lighting contribution including reflection and rim light.
 */
vec4 computeLighting(vec3 dir, vec3 N) {
    vec3 ref = reflect(dir, N);
    vec2 uv_ref = ref.xy * 0.5 + 0.5;

    float rim = max(0.0, 0.7 + dot(N, dir));
    vec4 rimColor = vec4(rim, rim * 0.5, 0.0, 1.0);
    vec4 reflection = texture(iChannel1, uv_ref) * 0.3;

    return rimColor + reflection;
}
