`ifndef MACROS
`define MACROS

`define PULSE_VAL_DELAY(thing,val,delay) begin thing = (val); #(delay); thing = 0; end
`define PULSE_VAL(thing,val) `PULSE_VAL_DELAY(thing,val,10)
`define PULSE_DELAY(thing,delay) `PULSE_VAL_DELAY(thing,1,delay)
`define PULSE(thing) `PULSE_VAL_DELAY(thing,1,10)

`define PULSEn(thing) begin thing = 0; #10; thing = 1; end

`endif // MACROS