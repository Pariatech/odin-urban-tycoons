package main

import "core:math"

Vec2 :: [2]f32
Vec3 :: [3]f32
Vec4 :: [4]f32

IVec2 :: [2]int
IVec3 :: [3]int
IVec4 :: [4]int

Mat4 :: matrix[4, 4]f32

cross :: proc(a, b: Vec3) -> Vec3 {
    i := a.yzx * b.zxy
    j := a.zxy * b.yzx
    return i - j
}

length :: proc(v: [$T]f32) -> f32 {
    sum: f32
    for a in v {
        sum += a * a
    }
    return math.sqrt(sum)
}

normalize :: proc(a: [$T]f32) -> [T]f32 {
    return a / length(a)
}

dot :: proc(a: [$T]f32, b: [T]f32) -> f32 {
    sum: f32
    for i in 0..<len(a) {
        sum += a[i] * b[i]
    }
    return sum
}
