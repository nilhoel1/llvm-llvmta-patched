; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=thumbv8.1m.main-none-none-eabi -O3 -mattr=+mve %s -o - | FileCheck %s

declare void @external_function()

define arm_aapcs_vfpcc void @spill_multivector(<4 x i32>* %p) {
; CHECK-LABEL: spill_multivector:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r4, r5, r7, lr}
; CHECK-NEXT:    push {r4, r5, r7, lr}
; CHECK-NEXT:    .vsave {d8, d9, d10, d11, d12, d13, d14, d15}
; CHECK-NEXT:    vpush {d8, d9, d10, d11, d12, d13, d14, d15}
; CHECK-NEXT:    .pad #112
; CHECK-NEXT:    sub sp, #112
; CHECK-NEXT:    vld20.32 {q0, q1}, [r0]
; CHECK-NEXT:    mov r5, r0
; CHECK-NEXT:    add.w lr, sp, #64
; CHECK-NEXT:    mov r4, r0
; CHECK-NEXT:    vld21.32 {q0, q1}, [r5]!
; CHECK-NEXT:    adds r0, #64
; CHECK-NEXT:    vstmia lr, {d0, d1, d2, d3} @ 32-byte Spill
; CHECK-NEXT:    add.w lr, sp, #32
; CHECK-NEXT:    vld20.32 {q0, q1}, [r0]
; CHECK-NEXT:    vld21.32 {q0, q1}, [r0]
; CHECK-NEXT:    add.w r0, r4, #128
; CHECK-NEXT:    vstmia lr, {d0, d1, d2, d3} @ 32-byte Spill
; CHECK-NEXT:    vld20.32 {q0, q1}, [r0]
; CHECK-NEXT:    vld21.32 {q0, q1}, [r0]
; CHECK-NEXT:    add.w r0, r4, #192
; CHECK-NEXT:    vstmia sp, {d0, d1, d2, d3} @ 32-byte Spill
; CHECK-NEXT:    vld20.32 {q6, q7}, [r0]
; CHECK-NEXT:    vld21.32 {q6, q7}, [r0]
; CHECK-NEXT:    add.w r0, r4, #256
; CHECK-NEXT:    vld20.32 {q4, q5}, [r0]
; CHECK-NEXT:    vld21.32 {q4, q5}, [r0]
; CHECK-NEXT:    bl external_function
; CHECK-NEXT:    vldmia sp, {d2, d3, d4, d5} @ 32-byte Reload
; CHECK-NEXT:    add r0, sp, #32
; CHECK-NEXT:    vstrw.32 q2, [r4, #80]
; CHECK-NEXT:    vstrw.32 q5, [r4, #144]
; CHECK-NEXT:    vstrw.32 q4, [r4, #128]
; CHECK-NEXT:    vstrw.32 q7, [r4, #112]
; CHECK-NEXT:    vstrw.32 q1, [r4, #64]
; CHECK-NEXT:    vldmia r0, {d2, d3, d4, d5} @ 32-byte Reload
; CHECK-NEXT:    add r0, sp, #64
; CHECK-NEXT:    vstrw.32 q2, [r4, #48]
; CHECK-NEXT:    vstrw.32 q6, [r4, #96]
; CHECK-NEXT:    vstrw.32 q1, [r5]
; CHECK-NEXT:    vldmia r0, {d2, d3, d4, d5} @ 32-byte Reload
; CHECK-NEXT:    vstrw.32 q2, [r4, #16]
; CHECK-NEXT:    vstrw.32 q1, [r4]
; CHECK-NEXT:    add sp, #112
; CHECK-NEXT:    vpop {d8, d9, d10, d11, d12, d13, d14, d15}
; CHECK-NEXT:    pop {r4, r5, r7, pc}
entry:
  %ip01 = bitcast <4 x i32>* %p to i32*
  %v01 = call { <4 x i32>, <4 x i32> } @llvm.arm.mve.vld2q.v4i32.v4i32.p0i32(i32* %ip01)
  %ip23 = getelementptr i32, i32* %ip01, i32 16
  %v23 = call { <4 x i32>, <4 x i32> } @llvm.arm.mve.vld2q.v4i32.v4i32.p0i32(i32* %ip23)
  %ip45 = getelementptr i32, i32* %ip23, i32 16
  %v45 = call { <4 x i32>, <4 x i32> } @llvm.arm.mve.vld2q.v4i32.v4i32.p0i32(i32* %ip45)
  %ip67 = getelementptr i32, i32* %ip45, i32 16
  %v67 = call { <4 x i32>, <4 x i32> } @llvm.arm.mve.vld2q.v4i32.v4i32.p0i32(i32* %ip67)
  %ip89 = getelementptr i32, i32* %ip67, i32 16
  %v89 = call { <4 x i32>, <4 x i32> } @llvm.arm.mve.vld2q.v4i32.v4i32.p0i32(i32* %ip89)
  call void @external_function()

  %v0 = extractvalue { <4 x i32>, <4 x i32> } %v01, 0
  %v1 = extractvalue { <4 x i32>, <4 x i32> } %v01, 1
  store <4 x i32> %v0, <4 x i32>* %p, align 4
  %p1 = getelementptr <4 x i32>, <4 x i32>* %p, i32 1
  store <4 x i32> %v1, <4 x i32>* %p1, align 4

  %v2 = extractvalue { <4 x i32>, <4 x i32> } %v23, 0
  %v3 = extractvalue { <4 x i32>, <4 x i32> } %v23, 1
  %p2 = getelementptr <4 x i32>, <4 x i32>* %p, i32 2
  store <4 x i32> %v2, <4 x i32>* %p2, align 4
  %p3 = getelementptr <4 x i32>, <4 x i32>* %p, i32 3
  store <4 x i32> %v3, <4 x i32>* %p3, align 4

  %v4 = extractvalue { <4 x i32>, <4 x i32> } %v45, 0
  %v5 = extractvalue { <4 x i32>, <4 x i32> } %v45, 1
  %p4 = getelementptr <4 x i32>, <4 x i32>* %p, i32 4
  store <4 x i32> %v4, <4 x i32>* %p4, align 4
  %p5 = getelementptr <4 x i32>, <4 x i32>* %p, i32 5
  store <4 x i32> %v5, <4 x i32>* %p5, align 4

  %v6 = extractvalue { <4 x i32>, <4 x i32> } %v67, 0
  %v7 = extractvalue { <4 x i32>, <4 x i32> } %v67, 1
  %p6 = getelementptr <4 x i32>, <4 x i32>* %p, i32 6
  store <4 x i32> %v6, <4 x i32>* %p6, align 4
  %p7 = getelementptr <4 x i32>, <4 x i32>* %p, i32 7
  store <4 x i32> %v7, <4 x i32>* %p7, align 4

  %v8 = extractvalue { <4 x i32>, <4 x i32> } %v89, 0
  %v9 = extractvalue { <4 x i32>, <4 x i32> } %v89, 1
  %p8 = getelementptr <4 x i32>, <4 x i32>* %p, i32 8
  store <4 x i32> %v8, <4 x i32>* %p8, align 4
  %p9 = getelementptr <4 x i32>, <4 x i32>* %p, i32 9
  store <4 x i32> %v9, <4 x i32>* %p9, align 4
  ret void
}

declare { <4 x i32>, <4 x i32> } @llvm.arm.mve.vld2q.v4i32.v4i32.p0i32(i32*)
