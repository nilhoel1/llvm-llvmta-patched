; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zfh -verify-machineinstrs \
; RUN:   -target-abi ilp32f < %s | FileCheck -check-prefix=RV32IZFH %s
; RUN: llc -mtriple=riscv64 -mattr=+experimental-zfh -verify-machineinstrs \
; RUN:   -target-abi lp64f < %s | FileCheck -check-prefix=RV64IZFH %s

define zeroext i1 @half_is_nan(half %a) nounwind {
; RV32IZFH-LABEL: half_is_nan:
; RV32IZFH:       # %bb.0:
; RV32IZFH-NEXT:    feq.h a0, fa0, fa0
; RV32IZFH-NEXT:    xori a0, a0, 1
; RV32IZFH-NEXT:    ret
;
; RV64IZFH-LABEL: half_is_nan:
; RV64IZFH:       # %bb.0:
; RV64IZFH-NEXT:    feq.h a0, fa0, fa0
; RV64IZFH-NEXT:    xori a0, a0, 1
; RV64IZFH-NEXT:    ret
  %1 = fcmp uno half %a, 0.000000e+00
  ret i1 %1
}

define zeroext i1 @half_not_nan(half %a) nounwind {
; RV32IZFH-LABEL: half_not_nan:
; RV32IZFH:       # %bb.0:
; RV32IZFH-NEXT:    feq.h a0, fa0, fa0
; RV32IZFH-NEXT:    ret
;
; RV64IZFH-LABEL: half_not_nan:
; RV64IZFH:       # %bb.0:
; RV64IZFH-NEXT:    feq.h a0, fa0, fa0
; RV64IZFH-NEXT:    ret
  %1 = fcmp ord half %a, 0.000000e+00
  ret i1 %1
}
