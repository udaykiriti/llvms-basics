define i32 @sieve(i32 %limit) {
entry:
  %ext = zext i32 %limit to i64
  %size = add i64 %ext, 1
  %arr = alloca i8, i64 %size, align 16

  %tooSml = icmp slt i32 %limit, 2
  br i1 %tooSml, label %exit, label %initPh

initPh:
  br label %init

init:
  %idx = phi i64 [ 2, %initPh ], [ %nextI, %init ]
  %ptr = getelementptr i8, i8* %arr, i64 %idx
  store i8 1, i8* %ptr, align 1
  %nextI = add nuw nsw i64 %idx, 1
  %done = icmp eq i64 %nextI, %size
  br i1 %done, label %outPh, label %init

outPh:
  br label %out

out:
  %i = phi i32 [ 2, %outPh ], [ %incI, %outInc ]
  %sq = mul nsw i32 %i, %i
  %stop = icmp sgt i32 %sq, %limit
  br i1 %stop, label %cntPh, label %check

check:
  %i64 = sext i32 %i to i64
  %pI = getelementptr i8, i8* %arr, i64 %i64
  %val = load i8, i8* %pI, align 1
  %isP = icmp ne i8 %val, 0
  br i1 %isP, label %inPh, label %outInc

inPh:
  br label %inner

inner:
  %j = phi i32 [ %sq, %inPh ], [ %nextJ, %inner ]
  %j64 = sext i32 %j to i64
  %pJ = getelementptr i8, i8* %arr, i64 %j64
  store i8 0, i8* %pJ, align 1
  %nextJ = add nsw i32 %j, %i
  %inEnd = icmp sgt i32 %nextJ, %limit
  br i1 %inEnd, label %outInc, label %inner

outInc:
  %incI = add nsw i32 %i, 1
  br label %out

cntPh:
  br label %count

count:
  %cnt = phi i32 [ 0, %cntPh ], [ %nextC, %cInc ]
  %k = phi i32 [ 2, %cntPh ], [ %nextK, %cInc ]
  %cEnd = icmp sgt i32 %k, %limit
  br i1 %cEnd, label %exit, label %cCheck

cCheck:
  %k64 = sext i32 %k to i64
  %pK = getelementptr i8, i8* %arr, i64 %k64
  %vK = load i8, i8* %pK, align 1
  %isK = icmp ne i8 %vK, 0
  %add = zext i1 %isK to i32
  %nextC = add nsw i32 %cnt, %add
  br label %cInc

cInc:
  %nextK = add nsw i32 %k, 1
  br label %count

exit:
  %res = phi i32 [ 0, %entry ], [ %cnt, %count ]
  ret i32 %res
}

declare i32 @printf(i8*, ...)

@fmt = private constant [18 x i8] c"Primes found: %d\0A\00"

define i32 @main() {
  %res = call i32 @sieve(i32 100)
  %ptr = getelementptr [18 x i8], [18 x i8]* @fmt, i32 0, i32 0
  call i32 (i8*, ...) @printf(i8* %ptr, i32 %res)
  ret i32 0
}
