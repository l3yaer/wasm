(module
 (func $print (import "env" "print") (param f32))
 (global $canvas_w (import "env" "canvas_w") i32)
 (global $canvas_h (import "env" "canvas_h") i32)
 (memory (import "env" "mem") 64)

 (func $fract
       (param $lhs i32)
       (param $rhs i32)
       (result f32)

       local.get $lhs
       f32.convert_i32_u

       local.get $rhs
       f32.convert_i32_u
       f32.div)

 (func $lerp
       (param $a i32)
       (param $b i32)
       (param $t f32)
       (result i32)

       local.get $b
       f32.convert_i32_u
       local.get $t
       f32.mul

       local.get $a
       f32.convert_i32_u
       f32.const 1
       local.get $t
       f32.sub
       f32.mul

       f32.add
       i32.trunc_f32_u)

 (func (export "draw")
       (local $x i32)
       (local $y i32)
       (local $shader_x f32)
       (local $shader_y f32)
       (local $index i32)

       i32.const -1
       local.set $x

       i32.const 0
       local.set $index

       (block $exit
         (loop $w_top

               local.get $x
               global.get $canvas_h
               i32.ge_s
               br_if $exit

               i32.const 1
               local.get $x
               i32.add
               local.tee $x

               global.get $canvas_h
               call $fract
               local.set $shader_y

               i32.const 0
               local.set $y

               f32.const 0.0
               local.set $shader_x

              (loop $h_top

                    local.get $y
                    global.get $canvas_w
                    i32.ge_s
                    br_if $w_top

                    ;; Red
                    local.get $index
                    i32.const 0xFF
                    i32.const 0x00
                    local.get $shader_y
                    call $lerp
                    i32.store

                    ;; Blue
                    local.get $index
                    i32.const 1
                    i32.add
                    i32.const 0x00
                    i32.const 0xFF
                    local.get $shader_y
                    call $lerp
                    i32.store

                    ;; Green
                    local.get $index
                    i32.const 2
                    i32.add
                    i32.const 0xFF
                    i32.store

                    ;;Alpha
                    local.get $index
                    i32.const 3
                    i32.add
                    i32.const 0xFF
                    i32.store

                    i32.const 1
                    local.get $y
                    i32.add
                    local.tee $y

                    global.get $canvas_w
                    call $fract
                    local.set $shader_x

                    i32.const 4
                    local.get $index
                    i32.add
                    local.set $index
                    br $h_top)))))
