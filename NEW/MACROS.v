`ifndef MACROS
`define MACROS

`define PULSE_VAL_DELAY(thing,val,delay) begin thing = (val); #(delay); thing = 0; end
`define PULSE_VAL(thing,val) `PULSE_VAL_DELAY(thing,val,10)
`define PULSE_DELAY(thing,delay) `PULSE_VAL_DELAY(thing,1,delay)
`define PULSE(thing) `PULSE_VAL_DELAY(thing,1,10)

`define PULSEn(thing) begin thing = 0; #10; thing = 1; end

`define TEST(test, i) begin \
    $display("Test %2d started  @%6d uS", i, $time/10); \
    test; \
    $display("Test %2d finished @%6d uS", i, $time/10); \
    i = i + 1; \
end

`define timeLog(str) begin $display("%5d uS: %s", $time/10, str); end

`endif // MACROS