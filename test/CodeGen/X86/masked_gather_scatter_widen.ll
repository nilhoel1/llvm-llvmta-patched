; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-unknown-linux-gnu -mattr=+avx512vl -mattr=+avx512dq < %s | FileCheck %s --check-prefix=WIDEN_SKX
; RUN: llc -mtriple=x86_64-unknown-linux-gnu -mattr=+avx512f < %s | FileCheck %s --check-prefix=WIDEN_KNL
; RUN: llc -mtriple=x86_64-unknown-linux-gnu -mcpu=skylake < %s | FileCheck %s --check-prefix=WIDEN_AVX2

define <2 x double> @test_gather_v2i32_index(double* %base, <2 x i32> %ind, <2 x i1> %mask, <2 x double> %src0) {
; WIDEN_SKX-LABEL: test_gather_v2i32_index:
; WIDEN_SKX:       # %bb.0:
; WIDEN_SKX-NEXT:    vpsllq $63, %xmm1, %xmm1
; WIDEN_SKX-NEXT:    vpmovq2m %xmm1, %k1
; WIDEN_SKX-NEXT:    vgatherdpd (%rdi,%xmm0,8), %xmm2 {%k1}
; WIDEN_SKX-NEXT:    vmovapd %xmm2, %xmm0
; WIDEN_SKX-NEXT:    retq
;
; WIDEN_KNL-LABEL: test_gather_v2i32_index:
; WIDEN_KNL:       # %bb.0:
; WIDEN_KNL-NEXT:    # kill: def $xmm2 killed $xmm2 def $zmm2
; WIDEN_KNL-NEXT:    # kill: def $xmm0 killed $xmm0 def $ymm0
; WIDEN_KNL-NEXT:    vpsllq $63, %xmm1, %xmm1
; WIDEN_KNL-NEXT:    vptestmq %zmm1, %zmm1, %k0
; WIDEN_KNL-NEXT:    kshiftlw $14, %k0, %k0
; WIDEN_KNL-NEXT:    kshiftrw $14, %k0, %k1
; WIDEN_KNL-NEXT:    vgatherdpd (%rdi,%ymm0,8), %zmm2 {%k1}
; WIDEN_KNL-NEXT:    vmovapd %xmm2, %xmm0
; WIDEN_KNL-NEXT:    vzeroupper
; WIDEN_KNL-NEXT:    retq
;
; WIDEN_AVX2-LABEL: test_gather_v2i32_index:
; WIDEN_AVX2:       # %bb.0:
; WIDEN_AVX2-NEXT:    vpsllq $63, %xmm1, %xmm1
; WIDEN_AVX2-NEXT:    vgatherdpd %xmm1, (%rdi,%xmm0,8), %xmm2
; WIDEN_AVX2-NEXT:    vmovapd %xmm2, %xmm0
; WIDEN_AVX2-NEXT:    retq
  %gep.random = getelementptr double, double* %base, <2 x i32> %ind
  %res = call <2 x double> @llvm.masked.gather.v2f64.v2p0f64(<2 x double*> %gep.random, i32 4, <2 x i1> %mask, <2 x double> %src0)
  ret <2 x double> %res
}

define void @test_scatter_v2i32_index(<2 x double> %a1, double* %base, <2 x i32> %ind, <2 x i1> %mask) {
; WIDEN_SKX-LABEL: test_scatter_v2i32_index:
; WIDEN_SKX:       # %bb.0:
; WIDEN_SKX-NEXT:    vpsllq $63, %xmm2, %xmm2
; WIDEN_SKX-NEXT:    vpmovq2m %xmm2, %k1
; WIDEN_SKX-NEXT:    vscatterdpd %xmm0, (%rdi,%xmm1,8) {%k1}
; WIDEN_SKX-NEXT:    retq
;
; WIDEN_KNL-LABEL: test_scatter_v2i32_index:
; WIDEN_KNL:       # %bb.0:
; WIDEN_KNL-NEXT:    # kill: def $xmm1 killed $xmm1 def $ymm1
; WIDEN_KNL-NEXT:    # kill: def $xmm0 killed $xmm0 def $zmm0
; WIDEN_KNL-NEXT:    vpsllq $63, %xmm2, %xmm2
; WIDEN_KNL-NEXT:    vptestmq %zmm2, %zmm2, %k0
; WIDEN_KNL-NEXT:    kshiftlw $14, %k0, %k0
; WIDEN_KNL-NEXT:    kshiftrw $14, %k0, %k1
; WIDEN_KNL-NEXT:    vscatterdpd %zmm0, (%rdi,%ymm1,8) {%k1}
; WIDEN_KNL-NEXT:    vzeroupper
; WIDEN_KNL-NEXT:    retq
;
; WIDEN_AVX2-LABEL: test_scatter_v2i32_index:
; WIDEN_AVX2:       # %bb.0:
; WIDEN_AVX2-NEXT:    vpmovsxdq %xmm1, %xmm1
; WIDEN_AVX2-NEXT:    vpsllq $3, %xmm1, %xmm1
; WIDEN_AVX2-NEXT:    vmovq %rdi, %xmm3
; WIDEN_AVX2-NEXT:    vpbroadcastq %xmm3, %xmm3
; WIDEN_AVX2-NEXT:    vpaddq %xmm1, %xmm3, %xmm1
; WIDEN_AVX2-NEXT:    vpsllq $63, %xmm2, %xmm2
; WIDEN_AVX2-NEXT:    vmovmskpd %xmm2, %eax
; WIDEN_AVX2-NEXT:    testb $1, %al
; WIDEN_AVX2-NEXT:    jne .LBB1_1
; WIDEN_AVX2-NEXT:  # %bb.2: # %else
; WIDEN_AVX2-NEXT:    testb $2, %al
; WIDEN_AVX2-NEXT:    jne .LBB1_3
; WIDEN_AVX2-NEXT:  .LBB1_4: # %else2
; WIDEN_AVX2-NEXT:    retq
; WIDEN_AVX2-NEXT:  .LBB1_1: # %cond.store
; WIDEN_AVX2-NEXT:    vmovq %xmm1, %rcx
; WIDEN_AVX2-NEXT:    vmovlps %xmm0, (%rcx)
; WIDEN_AVX2-NEXT:    testb $2, %al
; WIDEN_AVX2-NEXT:    je .LBB1_4
; WIDEN_AVX2-NEXT:  .LBB1_3: # %cond.store1
; WIDEN_AVX2-NEXT:    vpextrq $1, %xmm1, %rax
; WIDEN_AVX2-NEXT:    vmovhps %xmm0, (%rax)
; WIDEN_AVX2-NEXT:    retq
  %gep = getelementptr double, double *%base, <2 x i32> %ind
  call void @llvm.masked.scatter.v2f64.v2p0f64(<2 x double> %a1, <2 x double*> %gep, i32 4, <2 x i1> %mask)
  ret void
}

define <2 x i32> @test_gather_v2i32_data(<2 x i32*> %ptr, <2 x i1> %mask, <2 x i32> %src0) {
; WIDEN_SKX-LABEL: test_gather_v2i32_data:
; WIDEN_SKX:       # %bb.0:
; WIDEN_SKX-NEXT:    vpsllq $63, %xmm1, %xmm1
; WIDEN_SKX-NEXT:    vpmovq2m %xmm1, %k1
; WIDEN_SKX-NEXT:    vpgatherqd (,%xmm0), %xmm2 {%k1}
; WIDEN_SKX-NEXT:    vmovdqa %xmm2, %xmm0
; WIDEN_SKX-NEXT:    retq
;
; WIDEN_KNL-LABEL: test_gather_v2i32_data:
; WIDEN_KNL:       # %bb.0:
; WIDEN_KNL-NEXT:    # kill: def $xmm2 killed $xmm2 def $ymm2
; WIDEN_KNL-NEXT:    # kill: def $xmm0 killed $xmm0 def $zmm0
; WIDEN_KNL-NEXT:    vpsllq $63, %xmm1, %xmm1
; WIDEN_KNL-NEXT:    vptestmq %zmm1, %zmm1, %k0
; WIDEN_KNL-NEXT:    kshiftlw $14, %k0, %k0
; WIDEN_KNL-NEXT:    kshiftrw $14, %k0, %k1
; WIDEN_KNL-NEXT:    vpgatherqd (,%zmm0), %ymm2 {%k1}
; WIDEN_KNL-NEXT:    vmovdqa %xmm2, %xmm0
; WIDEN_KNL-NEXT:    vzeroupper
; WIDEN_KNL-NEXT:    retq
;
; WIDEN_AVX2-LABEL: test_gather_v2i32_data:
; WIDEN_AVX2:       # %bb.0:
; WIDEN_AVX2-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[0,2,2,3]
; WIDEN_AVX2-NEXT:    vpslld $31, %xmm1, %xmm1
; WIDEN_AVX2-NEXT:    vpgatherqd %xmm1, (,%xmm0), %xmm2
; WIDEN_AVX2-NEXT:    vmovdqa %xmm2, %xmm0
; WIDEN_AVX2-NEXT:    retq
  %res = call <2 x i32> @llvm.masked.gather.v2i32.v2p0i32(<2 x i32*> %ptr, i32 4, <2 x i1> %mask, <2 x i32> %src0)
  ret <2 x i32>%res
}

define void @test_scatter_v2i32_data(<2 x i32>%a1, <2 x i32*> %ptr, <2 x i1>%mask) {
; WIDEN_SKX-LABEL: test_scatter_v2i32_data:
; WIDEN_SKX:       # %bb.0:
; WIDEN_SKX-NEXT:    vpsllq $63, %xmm2, %xmm2
; WIDEN_SKX-NEXT:    vpmovq2m %xmm2, %k1
; WIDEN_SKX-NEXT:    vpscatterqd %xmm0, (,%xmm1) {%k1}
; WIDEN_SKX-NEXT:    retq
;
; WIDEN_KNL-LABEL: test_scatter_v2i32_data:
; WIDEN_KNL:       # %bb.0:
; WIDEN_KNL-NEXT:    # kill: def $xmm1 killed $xmm1 def $zmm1
; WIDEN_KNL-NEXT:    # kill: def $xmm0 killed $xmm0 def $ymm0
; WIDEN_KNL-NEXT:    vpsllq $63, %xmm2, %xmm2
; WIDEN_KNL-NEXT:    vptestmq %zmm2, %zmm2, %k0
; WIDEN_KNL-NEXT:    kshiftlw $14, %k0, %k0
; WIDEN_KNL-NEXT:    kshiftrw $14, %k0, %k1
; WIDEN_KNL-NEXT:    vpscatterqd %ymm0, (,%zmm1) {%k1}
; WIDEN_KNL-NEXT:    vzeroupper
; WIDEN_KNL-NEXT:    retq
;
; WIDEN_AVX2-LABEL: test_scatter_v2i32_data:
; WIDEN_AVX2:       # %bb.0:
; WIDEN_AVX2-NEXT:    vpsllq $63, %xmm2, %xmm2
; WIDEN_AVX2-NEXT:    vmovmskpd %xmm2, %eax
; WIDEN_AVX2-NEXT:    testb $1, %al
; WIDEN_AVX2-NEXT:    jne .LBB3_1
; WIDEN_AVX2-NEXT:  # %bb.2: # %else
; WIDEN_AVX2-NEXT:    testb $2, %al
; WIDEN_AVX2-NEXT:    jne .LBB3_3
; WIDEN_AVX2-NEXT:  .LBB3_4: # %else2
; WIDEN_AVX2-NEXT:    retq
; WIDEN_AVX2-NEXT:  .LBB3_1: # %cond.store
; WIDEN_AVX2-NEXT:    vmovq %xmm1, %rcx
; WIDEN_AVX2-NEXT:    vmovss %xmm0, (%rcx)
; WIDEN_AVX2-NEXT:    testb $2, %al
; WIDEN_AVX2-NEXT:    je .LBB3_4
; WIDEN_AVX2-NEXT:  .LBB3_3: # %cond.store1
; WIDEN_AVX2-NEXT:    vpextrq $1, %xmm1, %rax
; WIDEN_AVX2-NEXT:    vextractps $1, %xmm0, (%rax)
; WIDEN_AVX2-NEXT:    retq
  call void @llvm.masked.scatter.v2i32.v2p0i32(<2 x i32> %a1, <2 x i32*> %ptr, i32 4, <2 x i1> %mask)
  ret void
}

define <2 x i32> @test_gather_v2i32_data_index(i32* %base, <2 x i32> %ind, <2 x i1> %mask, <2 x i32> %src0) {
; WIDEN_SKX-LABEL: test_gather_v2i32_data_index:
; WIDEN_SKX:       # %bb.0:
; WIDEN_SKX-NEXT:    vpsllq $63, %xmm1, %xmm1
; WIDEN_SKX-NEXT:    vpmovq2m %xmm1, %k1
; WIDEN_SKX-NEXT:    vpgatherdd (%rdi,%xmm0,4), %xmm2 {%k1}
; WIDEN_SKX-NEXT:    vmovdqa %xmm2, %xmm0
; WIDEN_SKX-NEXT:    retq
;
; WIDEN_KNL-LABEL: test_gather_v2i32_data_index:
; WIDEN_KNL:       # %bb.0:
; WIDEN_KNL-NEXT:    # kill: def $xmm2 killed $xmm2 def $zmm2
; WIDEN_KNL-NEXT:    # kill: def $xmm0 killed $xmm0 def $zmm0
; WIDEN_KNL-NEXT:    vpsllq $63, %xmm1, %xmm1
; WIDEN_KNL-NEXT:    vptestmq %zmm1, %zmm1, %k0
; WIDEN_KNL-NEXT:    kshiftlw $14, %k0, %k0
; WIDEN_KNL-NEXT:    kshiftrw $14, %k0, %k1
; WIDEN_KNL-NEXT:    vpgatherdd (%rdi,%zmm0,4), %zmm2 {%k1}
; WIDEN_KNL-NEXT:    vmovdqa %xmm2, %xmm0
; WIDEN_KNL-NEXT:    vzeroupper
; WIDEN_KNL-NEXT:    retq
;
; WIDEN_AVX2-LABEL: test_gather_v2i32_data_index:
; WIDEN_AVX2:       # %bb.0:
; WIDEN_AVX2-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0,2],zero,zero
; WIDEN_AVX2-NEXT:    vpslld $31, %xmm1, %xmm1
; WIDEN_AVX2-NEXT:    vpgatherdd %xmm1, (%rdi,%xmm0,4), %xmm2
; WIDEN_AVX2-NEXT:    vmovdqa %xmm2, %xmm0
; WIDEN_AVX2-NEXT:    retq
  %gep.random = getelementptr i32, i32* %base, <2 x i32> %ind
  %res = call <2 x i32> @llvm.masked.gather.v2i32.v2p0i32(<2 x i32*> %gep.random, i32 4, <2 x i1> %mask, <2 x i32> %src0)
  ret <2 x i32> %res
}

define void @test_scatter_v2i32_data_index(<2 x i32> %a1, i32* %base, <2 x i32> %ind, <2 x i1> %mask) {
; WIDEN_SKX-LABEL: test_scatter_v2i32_data_index:
; WIDEN_SKX:       # %bb.0:
; WIDEN_SKX-NEXT:    vpsllq $63, %xmm2, %xmm2
; WIDEN_SKX-NEXT:    vpmovq2m %xmm2, %k1
; WIDEN_SKX-NEXT:    vpscatterdd %xmm0, (%rdi,%xmm1,4) {%k1}
; WIDEN_SKX-NEXT:    retq
;
; WIDEN_KNL-LABEL: test_scatter_v2i32_data_index:
; WIDEN_KNL:       # %bb.0:
; WIDEN_KNL-NEXT:    # kill: def $xmm1 killed $xmm1 def $zmm1
; WIDEN_KNL-NEXT:    # kill: def $xmm0 killed $xmm0 def $zmm0
; WIDEN_KNL-NEXT:    vpsllq $63, %xmm2, %xmm2
; WIDEN_KNL-NEXT:    vptestmq %zmm2, %zmm2, %k0
; WIDEN_KNL-NEXT:    kshiftlw $14, %k0, %k0
; WIDEN_KNL-NEXT:    kshiftrw $14, %k0, %k1
; WIDEN_KNL-NEXT:    vpscatterdd %zmm0, (%rdi,%zmm1,4) {%k1}
; WIDEN_KNL-NEXT:    vzeroupper
; WIDEN_KNL-NEXT:    retq
;
; WIDEN_AVX2-LABEL: test_scatter_v2i32_data_index:
; WIDEN_AVX2:       # %bb.0:
; WIDEN_AVX2-NEXT:    vpmovsxdq %xmm1, %xmm1
; WIDEN_AVX2-NEXT:    vpsllq $2, %xmm1, %xmm1
; WIDEN_AVX2-NEXT:    vmovq %rdi, %xmm3
; WIDEN_AVX2-NEXT:    vpbroadcastq %xmm3, %xmm3
; WIDEN_AVX2-NEXT:    vpaddq %xmm1, %xmm3, %xmm1
; WIDEN_AVX2-NEXT:    vpsllq $63, %xmm2, %xmm2
; WIDEN_AVX2-NEXT:    vmovmskpd %xmm2, %eax
; WIDEN_AVX2-NEXT:    testb $1, %al
; WIDEN_AVX2-NEXT:    jne .LBB5_1
; WIDEN_AVX2-NEXT:  # %bb.2: # %else
; WIDEN_AVX2-NEXT:    testb $2, %al
; WIDEN_AVX2-NEXT:    jne .LBB5_3
; WIDEN_AVX2-NEXT:  .LBB5_4: # %else2
; WIDEN_AVX2-NEXT:    retq
; WIDEN_AVX2-NEXT:  .LBB5_1: # %cond.store
; WIDEN_AVX2-NEXT:    vmovq %xmm1, %rcx
; WIDEN_AVX2-NEXT:    vmovss %xmm0, (%rcx)
; WIDEN_AVX2-NEXT:    testb $2, %al
; WIDEN_AVX2-NEXT:    je .LBB5_4
; WIDEN_AVX2-NEXT:  .LBB5_3: # %cond.store1
; WIDEN_AVX2-NEXT:    vpextrq $1, %xmm1, %rax
; WIDEN_AVX2-NEXT:    vextractps $1, %xmm0, (%rax)
; WIDEN_AVX2-NEXT:    retq
  %gep = getelementptr i32, i32 *%base, <2 x i32> %ind
  call void @llvm.masked.scatter.v2i32.v2p0i32(<2 x i32> %a1, <2 x i32*> %gep, i32 4, <2 x i1> %mask)
  ret void
}

define void @test_mscatter_v17f32(float* %base, <17 x i32> %index, <17 x float> %val)
; WIDEN_SKX-LABEL: test_mscatter_v17f32:
; WIDEN_SKX:       # %bb.0:
; WIDEN_SKX-NEXT:    vinsertps {{.*#+}} xmm4 = xmm4[0],xmm5[0],xmm4[2,3]
; WIDEN_SKX-NEXT:    vinsertps {{.*#+}} xmm4 = xmm4[0,1],xmm6[0],xmm4[3]
; WIDEN_SKX-NEXT:    vinsertps {{.*#+}} xmm4 = xmm4[0,1,2],xmm7[0]
; WIDEN_SKX-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[2,3]
; WIDEN_SKX-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1],xmm2[0],xmm0[3]
; WIDEN_SKX-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1,2],xmm3[0]
; WIDEN_SKX-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; WIDEN_SKX-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; WIDEN_SKX-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0],mem[0],xmm1[2,3]
; WIDEN_SKX-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0,1],mem[0],xmm1[3]
; WIDEN_SKX-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0,1,2],mem[0]
; WIDEN_SKX-NEXT:    vmovss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; WIDEN_SKX-NEXT:    vinsertps {{.*#+}} xmm2 = xmm2[0],mem[0],xmm2[2,3]
; WIDEN_SKX-NEXT:    vinsertps {{.*#+}} xmm2 = xmm2[0,1],mem[0],xmm2[3]
; WIDEN_SKX-NEXT:    vinsertps {{.*#+}} xmm2 = xmm2[0,1,2],mem[0]
; WIDEN_SKX-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; WIDEN_SKX-NEXT:    vinsertf64x4 $1, %ymm1, %zmm0, %zmm0
; WIDEN_SKX-NEXT:    vmovd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; WIDEN_SKX-NEXT:    vpinsrd $1, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; WIDEN_SKX-NEXT:    vpinsrd $2, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; WIDEN_SKX-NEXT:    vpinsrd $3, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; WIDEN_SKX-NEXT:    vmovd {{.*#+}} xmm2 = mem[0],zero,zero,zero
; WIDEN_SKX-NEXT:    vpinsrd $1, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; WIDEN_SKX-NEXT:    vpinsrd $2, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; WIDEN_SKX-NEXT:    vpinsrd $3, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; WIDEN_SKX-NEXT:    vinserti128 $1, %xmm2, %ymm1, %ymm1
; WIDEN_SKX-NEXT:    vmovd %esi, %xmm2
; WIDEN_SKX-NEXT:    vpinsrd $1, %edx, %xmm2, %xmm2
; WIDEN_SKX-NEXT:    vpinsrd $2, %ecx, %xmm2, %xmm2
; WIDEN_SKX-NEXT:    vpinsrd $3, %r8d, %xmm2, %xmm2
; WIDEN_SKX-NEXT:    vmovd %r9d, %xmm3
; WIDEN_SKX-NEXT:    vpinsrd $1, {{[0-9]+}}(%rsp), %xmm3, %xmm3
; WIDEN_SKX-NEXT:    vpinsrd $2, {{[0-9]+}}(%rsp), %xmm3, %xmm3
; WIDEN_SKX-NEXT:    vpinsrd $3, {{[0-9]+}}(%rsp), %xmm3, %xmm3
; WIDEN_SKX-NEXT:    vinserti128 $1, %xmm3, %ymm2, %ymm2
; WIDEN_SKX-NEXT:    vinserti64x4 $1, %ymm1, %zmm2, %zmm1
; WIDEN_SKX-NEXT:    vmovss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; WIDEN_SKX-NEXT:    vmovss {{.*#+}} xmm3 = mem[0],zero,zero,zero
; WIDEN_SKX-NEXT:    kxnorw %k0, %k0, %k1
; WIDEN_SKX-NEXT:    vscatterdps %zmm0, (%rdi,%zmm1,4) {%k1}
; WIDEN_SKX-NEXT:    movw $1, %ax
; WIDEN_SKX-NEXT:    kmovw %eax, %k1
; WIDEN_SKX-NEXT:    vscatterdps %zmm2, (%rdi,%zmm3,4) {%k1}
; WIDEN_SKX-NEXT:    vzeroupper
; WIDEN_SKX-NEXT:    retq
;
; WIDEN_KNL-LABEL: test_mscatter_v17f32:
; WIDEN_KNL:       # %bb.0:
; WIDEN_KNL-NEXT:    vinsertps {{.*#+}} xmm4 = xmm4[0],xmm5[0],xmm4[2,3]
; WIDEN_KNL-NEXT:    vinsertps {{.*#+}} xmm4 = xmm4[0,1],xmm6[0],xmm4[3]
; WIDEN_KNL-NEXT:    vinsertps {{.*#+}} xmm4 = xmm4[0,1,2],xmm7[0]
; WIDEN_KNL-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[2,3]
; WIDEN_KNL-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1],xmm2[0],xmm0[3]
; WIDEN_KNL-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1,2],xmm3[0]
; WIDEN_KNL-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; WIDEN_KNL-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; WIDEN_KNL-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0],mem[0],xmm1[2,3]
; WIDEN_KNL-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0,1],mem[0],xmm1[3]
; WIDEN_KNL-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0,1,2],mem[0]
; WIDEN_KNL-NEXT:    vmovss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; WIDEN_KNL-NEXT:    vinsertps {{.*#+}} xmm2 = xmm2[0],mem[0],xmm2[2,3]
; WIDEN_KNL-NEXT:    vinsertps {{.*#+}} xmm2 = xmm2[0,1],mem[0],xmm2[3]
; WIDEN_KNL-NEXT:    vinsertps {{.*#+}} xmm2 = xmm2[0,1,2],mem[0]
; WIDEN_KNL-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; WIDEN_KNL-NEXT:    vinsertf64x4 $1, %ymm1, %zmm0, %zmm0
; WIDEN_KNL-NEXT:    vmovd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; WIDEN_KNL-NEXT:    vpinsrd $1, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; WIDEN_KNL-NEXT:    vpinsrd $2, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; WIDEN_KNL-NEXT:    vpinsrd $3, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; WIDEN_KNL-NEXT:    vmovd {{.*#+}} xmm2 = mem[0],zero,zero,zero
; WIDEN_KNL-NEXT:    vpinsrd $1, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; WIDEN_KNL-NEXT:    vpinsrd $2, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; WIDEN_KNL-NEXT:    vpinsrd $3, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; WIDEN_KNL-NEXT:    vinserti128 $1, %xmm2, %ymm1, %ymm1
; WIDEN_KNL-NEXT:    vmovd %esi, %xmm2
; WIDEN_KNL-NEXT:    vpinsrd $1, %edx, %xmm2, %xmm2
; WIDEN_KNL-NEXT:    vpinsrd $2, %ecx, %xmm2, %xmm2
; WIDEN_KNL-NEXT:    vpinsrd $3, %r8d, %xmm2, %xmm2
; WIDEN_KNL-NEXT:    vmovd %r9d, %xmm3
; WIDEN_KNL-NEXT:    vpinsrd $1, {{[0-9]+}}(%rsp), %xmm3, %xmm3
; WIDEN_KNL-NEXT:    vpinsrd $2, {{[0-9]+}}(%rsp), %xmm3, %xmm3
; WIDEN_KNL-NEXT:    vpinsrd $3, {{[0-9]+}}(%rsp), %xmm3, %xmm3
; WIDEN_KNL-NEXT:    vinserti128 $1, %xmm3, %ymm2, %ymm2
; WIDEN_KNL-NEXT:    vinserti64x4 $1, %ymm1, %zmm2, %zmm1
; WIDEN_KNL-NEXT:    vmovss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; WIDEN_KNL-NEXT:    vmovss {{.*#+}} xmm3 = mem[0],zero,zero,zero
; WIDEN_KNL-NEXT:    kxnorw %k0, %k0, %k1
; WIDEN_KNL-NEXT:    vscatterdps %zmm0, (%rdi,%zmm1,4) {%k1}
; WIDEN_KNL-NEXT:    movw $1, %ax
; WIDEN_KNL-NEXT:    kmovw %eax, %k1
; WIDEN_KNL-NEXT:    vscatterdps %zmm2, (%rdi,%zmm3,4) {%k1}
; WIDEN_KNL-NEXT:    vzeroupper
; WIDEN_KNL-NEXT:    retq
;
; WIDEN_AVX2-LABEL: test_mscatter_v17f32:
; WIDEN_AVX2:       # %bb.0:
; WIDEN_AVX2-NEXT:    vmovq %rdi, %xmm8
; WIDEN_AVX2-NEXT:    vpbroadcastq %xmm8, %ymm9
; WIDEN_AVX2-NEXT:    vmovd %esi, %xmm10
; WIDEN_AVX2-NEXT:    vpinsrd $1, %edx, %xmm10, %xmm10
; WIDEN_AVX2-NEXT:    vpinsrd $2, %ecx, %xmm10, %xmm10
; WIDEN_AVX2-NEXT:    vpinsrd $3, %r8d, %xmm10, %xmm10
; WIDEN_AVX2-NEXT:    vpmovsxdq %xmm10, %ymm10
; WIDEN_AVX2-NEXT:    vpsllq $2, %ymm10, %ymm10
; WIDEN_AVX2-NEXT:    vpaddq %ymm10, %ymm9, %ymm10
; WIDEN_AVX2-NEXT:    vmovq %xmm10, %rax
; WIDEN_AVX2-NEXT:    vmovss %xmm0, (%rax)
; WIDEN_AVX2-NEXT:    vpextrq $1, %xmm10, %rax
; WIDEN_AVX2-NEXT:    vmovss %xmm1, (%rax)
; WIDEN_AVX2-NEXT:    vextracti128 $1, %ymm10, %xmm0
; WIDEN_AVX2-NEXT:    vmovq %xmm0, %rax
; WIDEN_AVX2-NEXT:    vmovss %xmm2, (%rax)
; WIDEN_AVX2-NEXT:    vpextrq $1, %xmm0, %rax
; WIDEN_AVX2-NEXT:    vmovss %xmm3, (%rax)
; WIDEN_AVX2-NEXT:    vmovd %r9d, %xmm0
; WIDEN_AVX2-NEXT:    vpinsrd $1, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; WIDEN_AVX2-NEXT:    vpinsrd $2, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; WIDEN_AVX2-NEXT:    vpinsrd $3, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; WIDEN_AVX2-NEXT:    vpmovsxdq %xmm0, %ymm0
; WIDEN_AVX2-NEXT:    vpsllq $2, %ymm0, %ymm0
; WIDEN_AVX2-NEXT:    vpaddq %ymm0, %ymm9, %ymm0
; WIDEN_AVX2-NEXT:    vmovq %xmm0, %rax
; WIDEN_AVX2-NEXT:    vmovss %xmm4, (%rax)
; WIDEN_AVX2-NEXT:    vpextrq $1, %xmm0, %rax
; WIDEN_AVX2-NEXT:    vmovss %xmm5, (%rax)
; WIDEN_AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm0
; WIDEN_AVX2-NEXT:    vmovq %xmm0, %rax
; WIDEN_AVX2-NEXT:    vmovss %xmm6, (%rax)
; WIDEN_AVX2-NEXT:    vpextrq $1, %xmm0, %rax
; WIDEN_AVX2-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; WIDEN_AVX2-NEXT:    vpinsrd $1, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; WIDEN_AVX2-NEXT:    vpinsrd $2, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; WIDEN_AVX2-NEXT:    vpinsrd $3, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; WIDEN_AVX2-NEXT:    vpmovsxdq %xmm0, %ymm0
; WIDEN_AVX2-NEXT:    vpsllq $2, %ymm0, %ymm0
; WIDEN_AVX2-NEXT:    vpaddq %ymm0, %ymm9, %ymm0
; WIDEN_AVX2-NEXT:    vmovss %xmm7, (%rax)
; WIDEN_AVX2-NEXT:    vmovd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; WIDEN_AVX2-NEXT:    vpinsrd $1, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; WIDEN_AVX2-NEXT:    vpinsrd $2, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; WIDEN_AVX2-NEXT:    vpinsrd $3, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; WIDEN_AVX2-NEXT:    vpmovsxdq %xmm1, %ymm1
; WIDEN_AVX2-NEXT:    vpsllq $2, %ymm1, %ymm1
; WIDEN_AVX2-NEXT:    vpaddq %ymm1, %ymm9, %ymm1
; WIDEN_AVX2-NEXT:    vmovss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; WIDEN_AVX2-NEXT:    vmovq %xmm1, %rax
; WIDEN_AVX2-NEXT:    vmovss %xmm2, (%rax)
; WIDEN_AVX2-NEXT:    vmovss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; WIDEN_AVX2-NEXT:    vpextrq $1, %xmm1, %rax
; WIDEN_AVX2-NEXT:    vmovss %xmm2, (%rax)
; WIDEN_AVX2-NEXT:    vmovss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; WIDEN_AVX2-NEXT:    vextracti128 $1, %ymm1, %xmm1
; WIDEN_AVX2-NEXT:    vmovq %xmm1, %rax
; WIDEN_AVX2-NEXT:    vmovss %xmm2, (%rax)
; WIDEN_AVX2-NEXT:    vpextrq $1, %xmm1, %rax
; WIDEN_AVX2-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; WIDEN_AVX2-NEXT:    vmovss %xmm1, (%rax)
; WIDEN_AVX2-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; WIDEN_AVX2-NEXT:    vmovq %xmm0, %rax
; WIDEN_AVX2-NEXT:    vmovss %xmm1, (%rax)
; WIDEN_AVX2-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; WIDEN_AVX2-NEXT:    vpextrq $1, %xmm0, %rax
; WIDEN_AVX2-NEXT:    vmovss %xmm1, (%rax)
; WIDEN_AVX2-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; WIDEN_AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm0
; WIDEN_AVX2-NEXT:    vmovq %xmm0, %rax
; WIDEN_AVX2-NEXT:    vmovss %xmm1, (%rax)
; WIDEN_AVX2-NEXT:    vpextrq $1, %xmm0, %rax
; WIDEN_AVX2-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; WIDEN_AVX2-NEXT:    vmovss %xmm0, (%rax)
; WIDEN_AVX2-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; WIDEN_AVX2-NEXT:    vpmovsxdq %xmm0, %xmm0
; WIDEN_AVX2-NEXT:    vpsllq $2, %xmm0, %xmm0
; WIDEN_AVX2-NEXT:    vpaddq %xmm0, %xmm8, %xmm0
; WIDEN_AVX2-NEXT:    vmovq %xmm0, %rax
; WIDEN_AVX2-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; WIDEN_AVX2-NEXT:    vmovss %xmm0, (%rax)
; WIDEN_AVX2-NEXT:    vzeroupper
; WIDEN_AVX2-NEXT:    retq
{
  %gep = getelementptr float, float* %base, <17 x i32> %index
  call void @llvm.masked.scatter.v17f32.v17p0f32(<17 x float> %val, <17 x float*> %gep, i32 4, <17 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>)
  ret void
}

define <17 x float> @test_mgather_v17f32(float* %base, <17 x i32> %index)
; WIDEN_SKX-LABEL: test_mgather_v17f32:
; WIDEN_SKX:       # %bb.0:
; WIDEN_SKX-NEXT:    movq %rdi, %rax
; WIDEN_SKX-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; WIDEN_SKX-NEXT:    vpinsrd $1, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; WIDEN_SKX-NEXT:    vpinsrd $2, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; WIDEN_SKX-NEXT:    vpinsrd $3, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; WIDEN_SKX-NEXT:    vmovd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; WIDEN_SKX-NEXT:    vpinsrd $1, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; WIDEN_SKX-NEXT:    vpinsrd $2, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; WIDEN_SKX-NEXT:    vpinsrd $3, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; WIDEN_SKX-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; WIDEN_SKX-NEXT:    vmovd %edx, %xmm1
; WIDEN_SKX-NEXT:    vpinsrd $1, %ecx, %xmm1, %xmm1
; WIDEN_SKX-NEXT:    vpinsrd $2, %r8d, %xmm1, %xmm1
; WIDEN_SKX-NEXT:    vpinsrd $3, %r9d, %xmm1, %xmm1
; WIDEN_SKX-NEXT:    vmovd {{.*#+}} xmm2 = mem[0],zero,zero,zero
; WIDEN_SKX-NEXT:    vpinsrd $1, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; WIDEN_SKX-NEXT:    vpinsrd $2, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; WIDEN_SKX-NEXT:    vpinsrd $3, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; WIDEN_SKX-NEXT:    vinserti128 $1, %xmm2, %ymm1, %ymm1
; WIDEN_SKX-NEXT:    vinserti64x4 $1, %ymm0, %zmm1, %zmm0
; WIDEN_SKX-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; WIDEN_SKX-NEXT:    kxnorw %k0, %k0, %k1
; WIDEN_SKX-NEXT:    vgatherdps (%rsi,%zmm0,4), %zmm2 {%k1}
; WIDEN_SKX-NEXT:    movw $1, %cx
; WIDEN_SKX-NEXT:    kmovw %ecx, %k1
; WIDEN_SKX-NEXT:    vgatherdps (%rsi,%zmm1,4), %zmm0 {%k1}
; WIDEN_SKX-NEXT:    vmovss %xmm0, 64(%rdi)
; WIDEN_SKX-NEXT:    vmovaps %zmm2, (%rdi)
; WIDEN_SKX-NEXT:    vzeroupper
; WIDEN_SKX-NEXT:    retq
;
; WIDEN_KNL-LABEL: test_mgather_v17f32:
; WIDEN_KNL:       # %bb.0:
; WIDEN_KNL-NEXT:    movq %rdi, %rax
; WIDEN_KNL-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; WIDEN_KNL-NEXT:    vpinsrd $1, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; WIDEN_KNL-NEXT:    vpinsrd $2, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; WIDEN_KNL-NEXT:    vpinsrd $3, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; WIDEN_KNL-NEXT:    vmovd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; WIDEN_KNL-NEXT:    vpinsrd $1, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; WIDEN_KNL-NEXT:    vpinsrd $2, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; WIDEN_KNL-NEXT:    vpinsrd $3, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; WIDEN_KNL-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; WIDEN_KNL-NEXT:    vmovd %edx, %xmm1
; WIDEN_KNL-NEXT:    vpinsrd $1, %ecx, %xmm1, %xmm1
; WIDEN_KNL-NEXT:    vpinsrd $2, %r8d, %xmm1, %xmm1
; WIDEN_KNL-NEXT:    vpinsrd $3, %r9d, %xmm1, %xmm1
; WIDEN_KNL-NEXT:    vmovd {{.*#+}} xmm2 = mem[0],zero,zero,zero
; WIDEN_KNL-NEXT:    vpinsrd $1, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; WIDEN_KNL-NEXT:    vpinsrd $2, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; WIDEN_KNL-NEXT:    vpinsrd $3, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; WIDEN_KNL-NEXT:    vinserti128 $1, %xmm2, %ymm1, %ymm1
; WIDEN_KNL-NEXT:    vinserti64x4 $1, %ymm0, %zmm1, %zmm0
; WIDEN_KNL-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; WIDEN_KNL-NEXT:    kxnorw %k0, %k0, %k1
; WIDEN_KNL-NEXT:    vgatherdps (%rsi,%zmm0,4), %zmm2 {%k1}
; WIDEN_KNL-NEXT:    movw $1, %cx
; WIDEN_KNL-NEXT:    kmovw %ecx, %k1
; WIDEN_KNL-NEXT:    vgatherdps (%rsi,%zmm1,4), %zmm0 {%k1}
; WIDEN_KNL-NEXT:    vmovss %xmm0, 64(%rdi)
; WIDEN_KNL-NEXT:    vmovaps %zmm2, (%rdi)
; WIDEN_KNL-NEXT:    vzeroupper
; WIDEN_KNL-NEXT:    retq
;
; WIDEN_AVX2-LABEL: test_mgather_v17f32:
; WIDEN_AVX2:       # %bb.0:
; WIDEN_AVX2-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; WIDEN_AVX2-NEXT:    vpinsrd $1, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; WIDEN_AVX2-NEXT:    vpinsrd $2, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; WIDEN_AVX2-NEXT:    vpinsrd $3, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; WIDEN_AVX2-NEXT:    vmovd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; WIDEN_AVX2-NEXT:    vpinsrd $1, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; WIDEN_AVX2-NEXT:    vpinsrd $2, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; WIDEN_AVX2-NEXT:    vpinsrd $3, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; WIDEN_AVX2-NEXT:    movq %rdi, %rax
; WIDEN_AVX2-NEXT:    vmovd %edx, %xmm2
; WIDEN_AVX2-NEXT:    vpinsrd $1, %ecx, %xmm2, %xmm2
; WIDEN_AVX2-NEXT:    vpinsrd $2, %r8d, %xmm2, %xmm2
; WIDEN_AVX2-NEXT:    vmovss {{.*#+}} xmm3 = mem[0],zero,zero,zero
; WIDEN_AVX2-NEXT:    vpinsrd $3, %r9d, %xmm2, %xmm2
; WIDEN_AVX2-NEXT:    vmovd {{.*#+}} xmm4 = mem[0],zero,zero,zero
; WIDEN_AVX2-NEXT:    vpinsrd $1, {{[0-9]+}}(%rsp), %xmm4, %xmm4
; WIDEN_AVX2-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; WIDEN_AVX2-NEXT:    vpinsrd $2, {{[0-9]+}}(%rsp), %xmm4, %xmm1
; WIDEN_AVX2-NEXT:    vpinsrd $3, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; WIDEN_AVX2-NEXT:    vinserti128 $1, %xmm1, %ymm2, %ymm1
; WIDEN_AVX2-NEXT:    vpcmpeqd %ymm2, %ymm2, %ymm2
; WIDEN_AVX2-NEXT:    vgatherdps %ymm2, (%rsi,%ymm1,4), %ymm4
; WIDEN_AVX2-NEXT:    vpcmpeqd %ymm1, %ymm1, %ymm1
; WIDEN_AVX2-NEXT:    vgatherdps %ymm1, (%rsi,%ymm0,4), %ymm2
; WIDEN_AVX2-NEXT:    vmovaps {{.*#+}} xmm0 = [4294967295,0,0,0]
; WIDEN_AVX2-NEXT:    vgatherdps %ymm0, (%rsi,%ymm3,4), %ymm1
; WIDEN_AVX2-NEXT:    vmovss %xmm1, 64(%rdi)
; WIDEN_AVX2-NEXT:    vmovaps %ymm2, 32(%rdi)
; WIDEN_AVX2-NEXT:    vmovaps %ymm4, (%rdi)
; WIDEN_AVX2-NEXT:    vzeroupper
; WIDEN_AVX2-NEXT:    retq
{
  %gep = getelementptr float, float* %base, <17 x i32> %index
  %res = call <17 x float> @llvm.masked.gather.v17f32.v17p0f32(<17 x float*> %gep, i32 4, <17 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, <17 x float> undef)
  ret <17 x float> %res
}

declare <17 x float> @llvm.masked.gather.v17f32.v17p0f32(<17 x float*>, i32 immarg, <17 x i1>, <17 x float>)
declare void @llvm.masked.scatter.v17f32.v17p0f32(<17 x float> , <17 x float*> , i32 , <17 x i1>)

declare <2 x double> @llvm.masked.gather.v2f64.v2p0f64(<2 x double*>, i32, <2 x i1>, <2 x double>)
declare void @llvm.masked.scatter.v2f64.v2p0f64(<2 x double>, <2 x double*>, i32, <2 x i1>)
declare <2 x i32> @llvm.masked.gather.v2i32.v2p0i32(<2 x i32*>, i32, <2 x i1>, <2 x i32>)
declare void @llvm.masked.scatter.v2i32.v2p0i32(<2 x i32> , <2 x i32*> , i32 , <2 x i1>)