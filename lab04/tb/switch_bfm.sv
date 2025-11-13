interface switch_bfm;
    
    bit                  clk;
    bit                  rst_n;
    bit                  prog;
    bit                  sin;
    bit                  sout0;
    bit                  sout1;
    logic        [10:0]  packet_0;
    logic        [10:0]  packet_1;
            
    initial begin
        clk = 0;
        forever begin
            #10;
            clk = ~clk;
        end
    end
    //------------------------
    //       Send data       |
    //------------------------
    
    //------------------------
    // Send UART packet (b1+b0)

    task send_uart(
        input logic [10:0] packet_0,
        input logic [10:0] packet_1
        ); 
        begin
            integer queue_index[$];
            foreach(packet_0[i]) begin
                sin = packet_0[i];
                repeat (16) @(posedge clk);
            end
            foreach(packet_1[i]) begin
                sin = packet_1[i];
                repeat (16) @(posedge clk);
            end
        end
    endtask
endinterface : switch_bfm
    