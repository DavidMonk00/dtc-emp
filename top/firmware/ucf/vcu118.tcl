delete_pblocks quad_R0
delete_pblocks quad_L0
add_cells_to_pblock payload [get_cells payload]

#set nSLICE 60

for { set y 6 } { $y < 15 } { incr y } {
    create_pblock p$y -parent payload
    #set y0 [expr $y * $nSLICE]
    #set y1 [expr ($y + 1) * $nSLICE - 1]
    #resize_pblock p$y -add SLICE_X15Y${y0}:SLICE_X153Y${y1}
    #set_property gridtypes {URAM288 RAMB36 RAMB18 DSP48E2 SLICE} [get_pblocks p${y}]
    resize_pblock p$y -add CLOCKREGION_X2Y${y}:CLOCKREGION_X3Y${y}
}
create_pblock p5 -parent payload
resize_pblock p5 -add CLOCKREGION_X1Y5:CLOCKREGION_X4Y5

for { set s 0 } { $s < 2 } { incr s } {
    for { set q 0 } { $q < 9 } { incr q } {
        for { set l 0 } { $l < 4 } { incr l } {
            set y [expr 6 + ${q}]
            set i [expr 4 * ${q} + ${l}]
            set k [expr 36 * ${s} + ${i}]
            add_cells_to_pblock p${y} [get_cells payload/DTC/cT/g[$k].c]
            add_cells_to_pblock p${y} [get_cells payload/DTC/cR/g[$s].c/cD/g[$i].c]
            add_cells_to_pblock p${y} [get_cells payload/DTC/cR/g[$s].c/cA/g[$i].c]
        }
    }
    add_cells_to_pblock p14 [get_cells payload/DTC/cR/g[$s].c/cR]
}

add_cells_to_pblock p5 [get_cells payload/DTC/cM]
