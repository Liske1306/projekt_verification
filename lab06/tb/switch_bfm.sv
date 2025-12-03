import switch_tb_pkg::*;

interface switch_bfm;
    
    bit                  clk;
    bit                  rst_n;
    bit                  prog;
    logic                sin;
    logic                sout0;
    logic                sout1;
    logic        [10:0]  packet_0;
    logic        [10:0]  packet_1;
            
    input_monitor input_monitor_h;
    output_monitor output_monitor_h;

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

    task automatic read_uart(
        ref uart_packet_sent temp_packet,
        ref logic signal
        ); 
        begin
            int i;
            repeat(8)@(posedge bfm.clk);
            temp_packet.packet_0[10]=signal;
            for (i=9; i>=0; i=i-1) begin 
                repeat(16) @(posedge bfm.clk);
                temp_packet.packet_0[i]=signal;
            end
            @(negedge signal);
            repeat(8)@(posedge bfm.clk);
            temp_packet.packet_1[10]=signal;
            for (i=9; i>=0; i=i-1) begin 
                repeat(16) @(posedge bfm.clk);
                temp_packet.packet_1[i]=signal;
            end
            repeat(8)@(posedge bfm.clk);
        end
    endtask
    
    task input_find();
        uart_packet_sent temp_packet_sin;
        int i;
        forever begin
            temp_packet_sin.is_prog=bfm.prog;
            @(negedge bfm.sin);
            read_uart(temp_packet_sin,bfm.sin);
            temp_packet_sin.timestamp=$time;
            input_monitor_h.write_to_monitor(temp_packet_sin);
        end
    endtask : input_find
    
    initial begin
        integer i;
        integer queue_index[$];
        uart_packet_sent temp_packet;
        forever begin
            @(negedge bfm.sout0 or negedge bfm.sout1);
            temp_packet.timestamp=$time;
            if(bfm.sout0==0 && bfm.sout1==0) begin  //check which port is active (err if both or none)
            end
            else if(bfm.sout0==0) begin 
                temp_packet.port=0; //save data from sout0
                read_uart(temp_packet,bfm.sout0);
                output_monitor_h.write_to_monitor(temp_packet);
            end
            else if(bfm.sout1==0) begin
                temp_packet.port=1; //save data from sout1
                read_uart(temp_packet,bfm.sout1);
                output_monitor_h.write_to_monitor(temp_packet);
            end
            else begin
            end
        end
    end
endinterface : switch_bfm
    