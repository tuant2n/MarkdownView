//
//  TestDocument.swift
//  Example
//
//  Created by 秋星桥 on 6/29/25.
//

import Foundation

let testDocument = ###"""
// Bubble Sort in 32 Languages

// 1. Swift
```swift
func bubbleSortSwift(_ arr: inout [Int]) {
    for i in 0..<arr.count {
        for j in 1..<arr.count - i {
            if arr[j-1] > arr[j] {
                arr.swapAt(j-1, j)
            }
        }
    }
}
```
- Swift 语言实现，使用 inout 参数原地排序，双重循环，内层比较并交换。

// 2. Python
```python
def bubble_sort_python(arr):
    for i in range(len(arr)):
        for j in range(1, len(arr)-i):
            if arr[j-1] > arr[j]:
                arr[j-1], arr[j] = arr[j], arr[j-1]
```
- Python 版本，利用元组交换，语法简洁。

// 3. JavaScript
```javascript
function bubbleSortJS(arr) {
    for (let i = 0; i < arr.length; i++) {
        for (let j = 1; j < arr.length - i; j++) {
            if (arr[j-1] > arr[j]) {
                [arr[j-1], arr[j]] = [arr[j], arr[j-1]];
            }
        }
    }
}
```
- JavaScript 版本，使用解构赋值交换数组元素。

// 4. Java
```java
void bubbleSortJava(int[] arr) {
    for (int i = 0; i < arr.length; i++) {
        for (int j = 1; j < arr.length - i; j++) {
            if (arr[j-1] > arr[j]) {
                int tmp = arr[j-1]; arr[j-1] = arr[j]; arr[j] = tmp;
            }
        }
    }
}
```
- Java 语言实现，标准 for 循环，使用临时变量交换。

// 5. C
```c
void bubbleSortC(int arr[], int n) {
    for (int i = 0; i < n; i++) {
        for (int j = 1; j < n - i; j++) {
            if (arr[j-1] > arr[j]) {
                int t = arr[j-1]; arr[j-1] = arr[j]; arr[j] = t;
            }
        }
    }
}
```
- C 语言实现，数组和长度参数，嵌套循环。

// 6. C++
```cpp
void bubbleSortCpp(std::vector<int>& arr) {
    for (size_t i = 0; i < arr.size(); i++) {
        for (size_t j = 1; j < arr.size() - i; j++) {
            if (arr[j-1] > arr[j]) std::swap(arr[j-1], arr[j]);
        }
    }
}
```
- C++ 版本，使用 std::vector 和 std::swap。

// 7. Go
```go
func bubbleSortGo(arr []int) {
    for i := 0; i < len(arr); i++ {
        for j := 1; j < len(arr)-i; j++ {
            if arr[j-1] > arr[j] {
                arr[j-1], arr[j] = arr[j], arr[j-1]
            }
        }
    }
}
```
- Go 语言实现，切片参数，原地交换。

// 8. Rust
```rust
fn bubble_sort_rust(arr: &mut [i32]) {
    for i in 0..arr.len() {
        for j in 1..arr.len()-i {
            if arr[j-1] > arr[j] {
                arr.swap(j-1, j);
            }
        }
    }
}
```
- Rust 语言实现，切片可变引用，swap 方法。

// 9. Kotlin
```kotlin
fun bubbleSortKotlin(arr: IntArray) {
    for (i in arr.indices) {
        for (j in 1 until arr.size - i) {
            if (arr[j-1] > arr[j]) {
                val t = arr[j-1]; arr[j-1] = arr[j]; arr[j] = t
            }
        }
    }
}
```
- Kotlin 语言实现，使用 until 和 indices。

// 10. C#
```csharp
void BubbleSortCSharp(int[] arr) {
    for (int i = 0; i < arr.Length; i++) {
        for (int j = 1; j < arr.Length - i; j++) {
            if (arr[j-1] > arr[j]) {
                int t = arr[j-1]; arr[j-1] = arr[j]; arr[j] = t;
            }
        }
    }
}
```
- C# 语言实现，数组参数，标准交换。

// 11. PHP
```php
function bubbleSortPHP(&$arr) {
    for ($i = 0; $i < count($arr); $i++) {
        for ($j = 1; $j < count($arr) - $i; $j++) {
            if ($arr[$j-1] > $arr[$j]) {
                $tmp = $arr[$j-1]; $arr[$j-1] = $arr[$j]; $arr[$j] = $tmp;
            }
        }
    }
}
```
- PHP 语言实现，引用传递数组。

// 12. Ruby
```ruby
def bubble_sort_ruby(arr)
  arr.size.times do |i|
    (1...(arr.size-i)).each do |j|
      arr[j-1], arr[j] = arr[j], arr[j-1] if arr[j-1] > arr[j]
    end
  end
end
```
- Ruby 语言实现，times 和 each 迭代，交换语法简洁。

// 13. Perl
```perl
sub bubble_sort_perl {
  my $arr = shift;
  for my $i (0..$#$arr) {
    for my $j (1..$#$arr-$i) {
      ($arr->[$j-1], $arr->[$j]) = ($arr->[$j], $arr->[$j-1]) if $arr->[$j-1] > $arr->[$j];
    }
  }
}
```
- Perl 语言实现，数组引用，交换语法。

// 14. Scala
```scala
def bubbleSortScala(arr: Array[Int]): Unit = {
  for (i <- arr.indices)
    for (j <- 1 until arr.length - i)
      if (arr(j-1) > arr(j)) {
        val t = arr(j-1); arr(j-1) = arr(j); arr(j) = t
      }
}
```
- Scala 语言实现，for 推导式，数组原地交换。

// 15. Haskell
```haskell
bubbleSortHaskell :: Ord a => [a] -> [a]
bubbleSortHaskell arr = foldl (\a _ -> pass a) arr [1..length arr]
  where pass (x:y:xs) | x > y = y : pass (x:xs)
        pass (x:xs) = x : pass xs
        pass [] = []
```
- Haskell 语言实现，递归与高阶函数。

// 16. Julia
```julia
function bubble_sort_julia!(arr)
    for i in 1:length(arr)
        for j in 2:(length(arr)-i+1)
            if arr[j-1] > arr[j]
                arr[j-1], arr[j] = arr[j], arr[j-1]
            end
        end
    end
end
```
- Julia 语言实现，感叹号表示原地修改。

// 17. Dart
```dart
void bubbleSortDart(List<int> arr) {
  for (int i = 0; i < arr.length; i++) {
    for (int j = 1; j < arr.length - i; j++) {
      if (arr[j-1] > arr[j]) {
        int t = arr[j-1]; arr[j-1] = arr[j]; arr[j] = t;
      }
    }
  }
}
```
- Dart 语言实现，List 参数，标准交换。

// 18. TypeScript
```typescript
function bubbleSortTS(arr: number[]): void {
  for (let i = 0; i < arr.length; i++) {
    for (let j = 1; j < arr.length - i; j++) {
      if (arr[j-1] > arr[j]) {
        [arr[j-1], arr[j]] = [arr[j], arr[j-1]];
      }
    }
  }
}
```
- TypeScript 语言实现，类型注解，解构交换。

// 19. Bash
```bash
bubble_sort_bash() {
  arr=("$@")
  for ((i=0; i<${#arr[@]}; i++)); do
    for ((j=1; j<${#arr[@]}-i; j++)); do
      if (( arr[j-1] > arr[j] )); then
        tmp=${arr[j-1]}; arr[j-1]=${arr[j]}; arr[j]=${tmp}
      fi
    done
  done
  echo "${arr[@]}"
}
```
- Bash 脚本实现，数组参数，循环与条件判断。

// 20. R
```r
bubble_sort_r <- function(arr) {
  for (i in seq_along(arr)) {
    for (j in 2:(length(arr)-i+1)) {
      if (arr[j-1] > arr[j]) {
        tmp <- arr[j-1]; arr[j-1] <- arr[j]; arr[j] <- tmp
      }
    }
  }
  arr
}
```
- R 语言实现，for 循环，原地交换。

// 21. Objective-C
```objective-c
void bubbleSortObjC(NSMutableArray *arr) {
    for (int i = 0; i < arr.count; i++) {
        for (int j = 1; j < arr.count - i; j++) {
            if ([arr[j-1] intValue] > [arr[j] intValue]) {
                [arr exchangeObjectAtIndex:j-1 withObjectAtIndex:j];
            }
        }
    }
}
```
- Objective-C 语言实现，使用 NSMutableArray 和消息传递。

// 22. Fortran
```fortran
subroutine bubble_sort_fortran(arr, n)
  integer, intent(inout) :: arr(:)
  integer, intent(in) :: n
  integer :: i, j, t
  do i = 1, n
    do j = 2, n-i+1
      if (arr(j-1) > arr(j)) then
        t = arr(j-1); arr(j-1) = arr(j); arr(j) = t
      end if
    end do
  end do
end subroutine
```
- Fortran 语言实现，子程序，数组参数。

// 23. Pascal
```pascal
procedure BubbleSortPascal(var arr: array of Integer);
var i, j, t: Integer;
begin
  for i := 0 to High(arr) do
    for j := 1 to High(arr)-i do
      if arr[j-1] > arr[j] then
      begin
        t := arr[j-1]; arr[j-1] := arr[j]; arr[j] := t;
      end;
end;
```
- Pascal 语言实现，过程，数组参数。

// 24. Lua
```lua
function bubble_sort_lua(arr)
  for i = 1, #arr do
    for j = 2, #arr-i+1 do
      if arr[j-1] > arr[j] then
        arr[j-1], arr[j] = arr[j], arr[j-1]
      end
    end
  end
end
```
- Lua 语言实现，数组下标从 1 开始。

// 25. Scheme
```scheme
(define (bubble-sort-scheme arr)
  (let loop ((a arr) (n (length arr)))
    (if (= n 0) a
        (loop (let pass ((a a) (j 1))
                (if (>= j n) a
                    (if (> (list-ref a (- j 1)) (list-ref a j))
                        (pass (let ((tmp (list-ref a (- j 1))))
                                (set! (list-ref a (- j 1)) (list-ref a j))
                                (set! (list-ref a j) tmp)
                                a) (+ j 1))
                        (pass a (+ j 1)))))
              (- n 1))))
```
- Scheme 语言实现，递归与列表操作。

// 26. F#
```fsharp
let bubbleSortF arr =
  for i in 0 .. Array.length arr - 1 do
    for j in 1 .. Array.length arr - i - 1 do
      if arr.[j-1] > arr.[j] then
        let t = arr.[j-1]
        arr.[j-1] <- arr.[j]
        arr.[j] <- t
```
- F# 语言实现，for 循环，数组可变。

// 27. OCaml
```ocaml
let bubble_sort_ocaml arr =
  for i = 0 to Array.length arr - 1 do
    for j = 1 to Array.length arr - i - 1 do
      if arr.(j-1) > arr.(j) then (
        let t = arr.(j-1) in arr.(j-1) <- arr.(j); arr.(j) <- t)
    done
  done
;;
```
- OCaml 语言实现，数组下标和可变性。

// 28. D
```d
void bubbleSortD(int[] arr) {
    foreach (i; 0 .. arr.length) {
        foreach (j; 1 .. arr.length - i) {
            if (arr[j-1] > arr[j]) {
                auto t = arr[j-1]; arr[j-1] = arr[j]; arr[j] = t;
            }
        }
    }
}
```
- D 语言实现，foreach 语法。

// 29. Visual Basic
```vbnet
Sub BubbleSortVB(arr() As Integer)
  Dim i As Integer, j As Integer, t As Integer
  For i = 0 To UBound(arr)
    For j = 1 To UBound(arr) - i
      If arr(j-1) > arr(j) Then
        t = arr(j-1): arr(j-1) = arr(j): arr(j) = t
      End If
    Next
  Next
End Sub
```
- Visual Basic 语言实现，Sub 过程。

// 30. SQL (pseudo)
```sql
-- Bubble sort is not practical in SQL, but for demonstration:
WITH RECURSIVE bubble_sort(arr, n) AS (
  SELECT arr, 0 FROM input
  UNION ALL
  SELECT sort_pass(arr, n), n+1 FROM bubble_sort WHERE n < array_length(arr, 1)
) SELECT arr FROM bubble_sort ORDER BY n DESC LIMIT 1;
```
- SQL 伪代码，仅演示递归思想。

// 31. Assembly (x86, pseudo)
```asm
; bubble_sort_asm:
;   mov ecx, n
; outer:
;   mov ebx, 1
; inner:
;     cmp arr[ebx-1], arr[ebx]
;     jle skip
;     xchg arr[ebx-1], arr[ebx]
;   skip:
;     inc ebx
;     cmp ebx, n-ecx
;     jl inner
;   loop outer
```
- x86 汇编伪代码，演示循环与交换。

// 32. MATLAB
```matlab
function arr = bubbleSortMatlab(arr)
  for i = 1:length(arr)
    for j = 2:(length(arr)-i+1)
      if arr(j-1) > arr(j)
        tmp = arr(j-1); arr(j-1) = arr(j); arr(j) = tmp;
      end
    end
  end
end
```
- MATLAB 语言实现，函数返回排序后数组。
"""###
