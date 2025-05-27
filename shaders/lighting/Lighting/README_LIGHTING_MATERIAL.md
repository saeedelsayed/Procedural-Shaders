// =============================================
// README: Shader Material & Lighting System
// Author: Xuetong Fu
// Description:
//   This documentation describes the structure, usage,
//   and integration process of the modular shader system,
//   including material presets, lighting models, and usage of the Hit struct.
// =============================================

// ---------------------------------------------
// struct Hit
// ---------------------------------------------
// Represents a ray-scene intersection result.
// Must be provided by the user's raymarcher or SDF traversal logic.
//
// Fields:
//   vec3 position   - world-space position of hit
//   int  id         - material ID (used for lookup in material library)
//   vec3 uv         - local coordinates or parameterization at hit

// ---------------------------------------------
// Module Workflow
// ---------------------------------------------
// Each pixel's shading is determined based on:
//   - Scene intersection result (Hit)
//   - Material lookup from hit.id (MaterialParams)
//   - LightingContext (view direction, light, etc.)
//   - Selected lighting model (Phong, PBR, etc.)

// Minimal example usage:

Hit hit = raymarchScene(cameraPos, rayDir);
MaterialParams mat = getMaterialFromHit(hit);

LightingContext ctx;
ctx.normal = estimateNormal(hit.position);
ctx.viewDir = normalize(cameraPos - hit.position);
ctx.lightDir = normalize(lightPos - hit.position);
ctx.lightColor = vec3(1.0);

vec3 color = applyPBRLighting(ctx, mat); // or use applyPhongLighting, etc.
fragColor = vec4(color, 1.0);

// ---------------------------------------------
// Required Shader Modules (include order recommended):
// ---------------------------------------------
//   #include "material_params.glsl"       // Defines MaterialParams
//   #include "material_presets.glsl"      // Contains makeX() functions
//   #include "material_library.glsl"      // getMaterialByID() mapping
//   #include "material_lookup.glsl"       // getMaterialFromHit(Hit)
//   #include "lighting_context.glsl"      // LightingInput/Context struct
//   #include "lighting_models.glsl"       // PBR / Phong / Rim lighting

// ---------------------------------------------
// Notes:
// - All material queries are per-pixel (fragment-level)
// - Lighting models expect normalized input directions
// - Material presets can be extended as needed
// - Material ID ranges: 1-99 (common materials), 100+ (scene-specific)

// =============================================
// End of README
