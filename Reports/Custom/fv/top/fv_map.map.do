
//input ports
add mapped point clk clk -type PI PI
add mapped point rst rst -type PI PI

//output ports
add mapped point key[3] key[3] -type PO PO
add mapped point key[2] key[2] -type PO PO
add mapped point key[1] key[1] -type PO PO
add mapped point key[0] key[0] -type PO PO

//inout ports
add mapped point rows[3] rows[3]
add mapped point rows[2] rows[2]
add mapped point rows[1] rows[1]
add mapped point rows[0] rows[0]
add mapped point cols[3] cols[3]
add mapped point cols[2] cols[2]
add mapped point cols[1] cols[1]
add mapped point cols[0] cols[0]




//Sequential Pins
add mapped point state[0]/q state_reg[0]/Q -type DFF DFF
add mapped point state[1]/q state_reg[1]/Q -type DFF DFF
add mapped point drive_cols_tri_enable_reg[0]/q drive_cols_reg[0]160/Q -type DFF DFF
add mapped point drive_rows_tri_enable_reg[0]/q drive_rows_reg[0]156/Q -type DFF DFF
add mapped point state[2]/q state_reg[2]/Q -type DFF DFF



//Black Boxes



//Empty Modules as Blackboxes
