(module
 (func $print (import "env" "print") (param i32))
 (func $atan2 (import "env" "atan2") (param f32 f32) (result f32))
 (func $sin   (import "env" "sin")   (param f32) (result f32))
 (func $cos   (import "env" "cos")   (param f32) (result f32))

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

 (func $max
       (param $lhs f32)
       (param $rhs f32)
       (result f32)
       local.get $lhs
       local.get $rhs
       f32.gt
       if
       local.get $lhs
       return
       end
       local.get $rhs)

 (func $v_length
       (param $x f32)
       (param $y f32)
       (result f32)

       local.get $x
       local.get $x
       f32.mul

       local.get $y
       local.get $y
       f32.mul

       f32.add
       f32.sqrt)

 (func $wave
       (param $x i32)
       (param $coord f32)
       (result i32)

       local.get $x
       f32.convert_i32_u

       local.get $coord
       call $sin
       ;; Wave size
       f32.const 110.0
       f32.mul
       call $cos
       ;; Wave blend
       f32.const 0.2
       f32.mul
       ;; 1 - Wave blend
       f32.const 0.8
       f32.add
       f32.mul

       local.get $coord
       call $cos
       ;; Wave size
       f32.const 110.0
       f32.mul
       call $cos
       ;; Wave blend
       f32.const 0.2
       f32.mul
       ;; 1 - Wave blend
       f32.const 0.8
       f32.add
       f32.mul

       i32.trunc_f32_u)

 (func $sd_moon
       (param $p_x f32)
       (param $p_y f32)
       (param $d f32)
       (param $ra f32)
       (param $rb f32)
       (result f32)
       local.get $p_x
       local.get $p_y
       local.get $ra
       call $sd_sphere

       
       local.get $p_x
       local.get $d
       f32.sub
       local.get $p_y
       local.get $d
       f32.add
       local.get $rb
       call $sd_sphere
       f32.neg
       
       call $max)

 (func $sd_sphere
       (param $x f32)
       (param $y f32)
       (param $r f32)
       (result f32)

       local.get $x
       local.get $y
       call $v_length

       local.get $r
       f32.sub)

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

 (func $draw_pixel
       (param $x f32)
       (param $y f32)
       (param $ptr i32)

       ;; Red
       local.get $ptr
       i32.const 0xFF
       i32.const 0x00
       local.get $y
       call $lerp
       i32.store

       ;; Blue
       ;; Sphere
       ;; Center on screen
       local.get $x
       f32.const 0.5
       f32.sub
       local.get $y
       f32.const 0.5
       f32.sub
       ;; Distance
       f32.const 0.15
       
       ;; Outer radius
       f32.const 0.4
       
       ;; Inner radius
       f32.const 0.35
       call $sd_moon
       f32.const 0
       f32.lt

       if

       local.get $ptr
       i32.const 1
       i32.add
       i32.const 0x00
       i32.store

       else

       local.get $ptr
       i32.const 1
       i32.add
       i32.const 0x00
       i32.const 0xFF
       local.get $y
       call $lerp
       local.get $y
       call $wave
       i32.store
       end

       ;;Green
       local.get $ptr
       i32.const 2
       i32.add
       i32.const 0xFF
       i32.store

       ;;Alpha
       local.get $ptr
       i32.const 3
       i32.add
       i32.const 0xFF
       i32.store)

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

       block $exit
       loop $w_top

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

       loop $h_top

       local.get $y
       global.get $canvas_w
       i32.ge_s
       br_if $w_top

       local.get $shader_x
       local.get $shader_y
       local.get $index
       call $draw_pixel

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
       br $h_top
       end ;;h_top
       end ;;w_top
       end)  ;;exit
)
