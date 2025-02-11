`ifndef MACROS
`define MACROS

`define PULSE_VAL_DELAY(x,val,delay) begin x = val; #delay; x = 0; end
`define PULSE_VAL(x,val) `PULSE_VAL_DELAY(x,val,10)
`define PULSE_DELAY(x,delay) `PULSE_VAL_DELAY(x,1,delay)
`define PULSE(x) `PULSE_VAL_DELAY(x,1,10)

`endif // MACROS