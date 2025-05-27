#ifndef SDF_ANIMATION_GLSL
#define SDF_ANIMATION_GLSL

// ===================================
// sdf_animation.glsl
// Modular animation system for SDFs based on time and type.
//
// Supported animation types:
// 1 – Translate          (move along direction)
// 2 – Self Rotation      (spin around Z or arbitrary axis)
// 3 – Orbit Rotation     (rotate around a point)
// 4 – Pulsing Scale      (scale by sinusoidal function)
// 5 – TIE Fighter Path   (predefined complex motion)
//
// Each SDF is animated via:
//     SDF animateSDF(SDF sdf, float t, Animation anim);
//     void animateAllSDFs(SDF[], Animation[], float t);

// ===================================

struct SDF {
    int type;
    vec3 position;
    vec3 size;
    float radius;
};

struct Animation {
    int type;
    vec3 param;
};

// === rotateAroundAxis ===
vec3 rotateAroundAxis(vec3 pos, vec3 center, vec3 axis, float angle) {
    vec3 p = pos - center;
    axis = normalize(axis);

    float c = cos(angle);
    float s = sin(angle);
    float ic = 1.0 - c;

    mat3 R = mat3(
        c + axis.x * axis.x * ic, axis.x * axis.y * ic - axis.z * s, axis.x * axis.z * ic + axis.y * s,
        axis.y * axis.x * ic + axis.z * s, c + axis.y * axis.y * ic, axis.y * axis.z * ic - axis.x * s,
        axis.z * axis.x * ic - axis.y * s, axis.z * axis.y * ic + axis.x * s, c + axis.z * axis.z * ic
    );

    return R * p + center;
}

// === Type 1: Translation ===
SDF animateTranslate(SDF sdf, float t, vec3 param) {
    sdf.position += param * sin(t);
    return sdf;
}

// === Type 2: Self-rotation ===
SDF animateRotateSelf(SDF sdf, float t, vec3 param) {
    vec3 axis;
    float speed;

    if (param.y == 0.0 && param.z == 0.0) {
        axis = vec3(0.0, 0.0, 1.0);
        speed = param.x;
    }
    else {
        axis = normalize(param);
        speed = length(param);
    }

    float angle = t * speed;
    sdf.position = rotateAroundAxis(sdf.position, vec3(0.0), axis, angle);
    return sdf;
}

// === Type 3: Orbit  ===
SDF animateRotateOrbit(SDF sdf, float t, vec3 param) {
    vec3 axis;
    vec3 center;
    float angle;

    if (param.y != 0.0 || param.z != 0.0) {
        center = vec3(param.x, param.y, 0.0);
        axis = vec3(0.0, 0.0, 1.0);
        angle = t * param.z;
    }
    else {
        center = vec3(0.0, 0.0, 3.0);
        axis = vec3(0.0, 1.0, 0.0);
        angle = t * param.x;
    }

    sdf.position = rotateAroundAxis(sdf.position, center, axis, angle);
    return sdf;
}

// === Type 4: Pulsing Scale ===
SDF animateScale(SDF sdf, float t, vec3 param) {
    float scale = 1.0 + param.y * sin(t * param.x);
    sdf.size *= scale;
    sdf.radius *= scale;
    return sdf;
}

// === Type 5: Predefined TIE Fighter Path ===
vec3 tiePos(vec3 p, float t) {
    float x = cos(t * 0.7);
    p += vec3(x, cos(t), sin(t * 1.1));
    p.xy *= mat2(cos(-x * 0.1), sin(-x * 0.1), -sin(-x * 0.1), cos(-x * 0.1));
    return p;
}

SDF animateTIEPath(SDF sdf, float t, vec3 param) {
    sdf.position = tiePos(sdf.position, t);
    return sdf;
}

// === Dispatcher ===
SDF animateSDF(SDF sdf, float t, Animation anim) {
    if (anim.type == 1) return animateTranslate(sdf, t, anim.param);
    if (anim.type == 2) return animateRotateSelf(sdf, t, anim.param);
    if (anim.type == 3) return animateRotateOrbit(sdf, t, anim.param);
    if (anim.type == 4) return animateScale(sdf, t, anim.param);
    if (anim.type == 5) return animateTIEPath(sdf, t, anim.param);
    return sdf;
}

// === Batch Dispatcher ===
void animateAllSDFs(inout SDF sdfArray[10], Animation animArray[10], float t) {
    for (int i = 0; i < 10; ++i) {
        sdfArray[i] = animateSDF(sdfArray[i], t, animArray[i]);
    }
}

#endif
