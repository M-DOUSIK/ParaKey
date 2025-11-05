
//input ports
add mapped point Clock Clock -type PI PI
add mapped point ResetButton ResetButton -type PI PI
add mapped point KeyRead KeyRead -type PI PI
add mapped point RowDataIn[3] RowDataIn[3] -type PI PI
add mapped point RowDataIn[2] RowDataIn[2] -type PI PI
add mapped point RowDataIn[1] RowDataIn[1] -type PI PI
add mapped point RowDataIn[0] RowDataIn[0] -type PI PI

//output ports
add mapped point KeyReady KeyReady -type PO PO
add mapped point DataOut[3] DataOut[3] -type PO PO
add mapped point DataOut[2] DataOut[2] -type PO PO
add mapped point DataOut[1] DataOut[1] -type PO PO
add mapped point DataOut[0] DataOut[0] -type PO PO
add mapped point ColDataOut[3] ColDataOut[3] -type PO PO
add mapped point ColDataOut[2] ColDataOut[2] -type PO PO
add mapped point ColDataOut[1] ColDataOut[1] -type PO PO
add mapped point ColDataOut[0] ColDataOut[0] -type PO PO
add mapped point PressCount[3] PressCount[3] -type PO PO
add mapped point PressCount[2] PressCount[2] -type PO PO
add mapped point PressCount[1] PressCount[1] -type PO PO
add mapped point PressCount[0] PressCount[0] -type PO PO

//inout ports




//Sequential Pins



//Black Boxes
add mapped point Count Count -type BBOX BBOX
add mapped point Decoder Decoder -type BBOX BBOX
add mapped point LFSR LFSR -type BBOX BBOX
add mapped point Scanner Scanner -type BBOX BBOX



//Empty Modules as Blackboxes
