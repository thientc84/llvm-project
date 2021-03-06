; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -mtriple=x86_64-linux -codegenprepare -S < %s | FileCheck %s

define i32 @test_01(i32* %p, i64 %len, i32 %x) {
; CHECK-LABEL: @test_01(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[MATH:%.*]], [[BACKEDGE:%.*]] ], [ [[LEN:%.*]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = call { i64, i1 } @llvm.usub.with.overflow.i64(i64 [[IV]], i64 1)
; CHECK-NEXT:    [[MATH]] = extractvalue { i64, i1 } [[TMP0]], 0
; CHECK-NEXT:    [[OV:%.*]] = extractvalue { i64, i1 } [[TMP0]], 1
; CHECK-NEXT:    br i1 [[OV]], label [[EXIT:%.*]], label [[BACKEDGE]]
; CHECK:       backedge:
; CHECK-NEXT:    [[SUNKADDR:%.*]] = mul i64 [[IV]], 4
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i32* [[P:%.*]] to i8*
; CHECK-NEXT:    [[SUNKADDR1:%.*]] = getelementptr i8, i8* [[TMP1]], i64 [[SUNKADDR]]
; CHECK-NEXT:    [[SUNKADDR2:%.*]] = getelementptr i8, i8* [[SUNKADDR1]], i64 -4
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i8* [[SUNKADDR2]] to i32*
; CHECK-NEXT:    [[LOADED:%.*]] = load atomic i32, i32* [[TMP2]] unordered, align 4
; CHECK-NEXT:    [[COND_2:%.*]] = icmp eq i32 [[LOADED]], [[X:%.*]]
; CHECK-NEXT:    br i1 [[COND_2]], label [[FAILURE:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret i32 -1
; CHECK:       failure:
; CHECK-NEXT:    unreachable
;
entry:
  %scevgep = getelementptr i32, i32* %p, i64 -1
  br label %loop

loop:                                             ; preds = %backedge, %entry
  %iv = phi i64 [ %iv.next, %backedge ], [ %len, %entry ]
  %iv.next = add i64 %iv, -1
  %cond_1 = icmp eq i64 %iv, 0
  br i1 %cond_1, label %exit, label %backedge

backedge:                                         ; preds = %loop
  %scevgep1 = getelementptr i32, i32* %scevgep, i64 %iv
  %loaded = load atomic i32, i32* %scevgep1 unordered, align 4
  %cond_2 = icmp eq i32 %loaded, %x
  br i1 %cond_2, label %failure, label %loop

exit:                                             ; preds = %loop
  ret i32 -1

failure:                                          ; preds = %backedge
  unreachable
}

; TODO: We can use trick with usub here.
define i32 @test_02(i32* %p, i64 %len, i32 %x) {
; CHECK-LABEL: @test_02(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[BACKEDGE:%.*]] ], [ [[LEN:%.*]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[COND_1:%.*]] = icmp eq i64 [[IV]], 0
; CHECK-NEXT:    br i1 [[COND_1]], label [[EXIT:%.*]], label [[BACKEDGE]]
; CHECK:       backedge:
; CHECK-NEXT:    [[SUNKADDR:%.*]] = mul i64 [[IV]], 4
; CHECK-NEXT:    [[TMP0:%.*]] = bitcast i32* [[P:%.*]] to i8*
; CHECK-NEXT:    [[SUNKADDR1:%.*]] = getelementptr i8, i8* [[TMP0]], i64 [[SUNKADDR]]
; CHECK-NEXT:    [[SUNKADDR2:%.*]] = getelementptr i8, i8* [[SUNKADDR1]], i64 -4
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i8* [[SUNKADDR2]] to i32*
; CHECK-NEXT:    [[LOADED:%.*]] = load atomic i32, i32* [[TMP1]] unordered, align 4
; CHECK-NEXT:    [[COND_2:%.*]] = icmp eq i32 [[LOADED]], [[X:%.*]]
; CHECK-NEXT:    [[IV_NEXT]] = add i64 [[IV]], -1
; CHECK-NEXT:    br i1 [[COND_2]], label [[FAILURE:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret i32 -1
; CHECK:       failure:
; CHECK-NEXT:    unreachable
;
entry:
  %scevgep = getelementptr i32, i32* %p, i64 -1
  br label %loop

loop:                                             ; preds = %backedge, %entry
  %iv = phi i64 [ %iv.next, %backedge ], [ %len, %entry ]
  %cond_1 = icmp eq i64 %iv, 0
  br i1 %cond_1, label %exit, label %backedge

backedge:                                         ; preds = %loop
  %scevgep1 = getelementptr i32, i32* %scevgep, i64 %iv
  %loaded = load atomic i32, i32* %scevgep1 unordered, align 4
  %cond_2 = icmp eq i32 %loaded, %x
  %iv.next = add i64 %iv, -1
  br i1 %cond_2, label %failure, label %loop

exit:                                             ; preds = %loop
  ret i32 -1

failure:                                          ; preds = %backedge
  unreachable
}
