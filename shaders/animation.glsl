// ==========================================
// Shader: Camera Orientation Setup Shader
// Category: Animation / Camera
// Description: 
//   Defines a dynamic camera system using a "look at" matrix with support 
//   for orbital motion around the origin and optional roll. This allows 
//   the camera to animate smoothly around the scene.
// ==========================================

/**
 * Function: calcLookAtMatrix
 * Description: Computes a camera basis matrix from eye position, target, and roll.
 * Input:
 *   - ro (vec3): Camera (eye) position.
 *   - ta (vec3): Target position to look at.
 *   - roll (float): Roll angle in radians for camera rotation.
 * Output:
 *   - mat3: Camera rotation matrix (right, up, forward).
 */
mat3 calcLookAtMatrix(vec3 ro, vec3 ta, float roll) {
    vec3 forward = normalize(ta - ro);
    vec3 right = normalize(cross(forward, vec3(sin(roll), cos(roll), 0.0)));
    vec3 up = normalize(cross(right, forward));
    return mat3(right, up, forward);
}
