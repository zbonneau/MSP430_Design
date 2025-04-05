task timer_test;
    integer i;
    begin
    i = 0;
    
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h4031; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h2400; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h40B0; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h02C0; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'hBF38; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h43A0; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'hBF54; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h40B2; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h7A12; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h0352; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h40B2; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h0010; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h0342; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'hD2A0; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'hBF24; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'hD0B0; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h0010; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'hBF1E; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h43F0; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'hBDDE; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h43C0; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'hBDD8; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h3FFF; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h4303; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'hE3D0; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'hBDD0; i = i+2;
    {uut.FRAM.memory[i+1], uut.FRAM.memory[i]} = 16'h1300; i = i+2;

    i = 0;

    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'hFFFF; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4430; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4436; i = i + 2;
    {uut.IVT.memory[i+1], uut.IVT.memory[i]} = 16'h4400; i = i + 2;

    i = 0;

    // Execute program, Drive external events
    #(300 * CLK_PERIOD);

    end
endtask