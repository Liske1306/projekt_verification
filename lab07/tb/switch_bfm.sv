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
            repeat(8)@(posedge clk);
            temp_packet.packet_0[10]=signal;
            for (i=9; i>=0; i=i-1) begin 
                repeat(16) @(posedge clk);
                temp_packet.packet_0[i]=signal;
            end
            @(negedge signal);
            repeat(8)@(posedge clk);
            temp_packet.packet_1[10]=signal;
            for (i=9; i>=0; i=i-1) begin 
                repeat(16) @(posedge clk);
                temp_packet.packet_1[i]=signal;
            end
            repeat(8)@(posedge clk);
        end
    endtask
    
    initial begin
        input_transaction temp_packet_sin;
        uart_packet_sent very_needed;
        int i;
        temp_packet_sin = new("temp_packet_sin");
        forever begin
            temp_packet_sin.is_prog=prog;
            @(negedge sin);
            read_uart(very_needed,sin);
            temp_packet_sin.packet_0 = very_needed.packet_0;
            temp_packet_sin.packet_1 = very_needed.packet_1;
            temp_packet_sin.is_prog = very_needed.is_prog;
            input_monitor_h.write_to_monitor(temp_packet_sin);
        end
    end
    
    initial begin
        integer i;
        integer queue_index[$];
        uart_packet_sent temp_packet;
        output_transaction very_important;
        very_important=new("very_important");
        forever begin
            @(negedge sout0 or negedge sout1);
            if(sout0==0 && sout1==0) begin  //check which port is active (err if both or none)
            end
            else if(sout0==0) begin 
                temp_packet.port=0; //save data from sout0
                read_uart(temp_packet,sout0);
                very_important.output_packets = temp_packet;
                output_monitor_h.write_to_monitor(very_important);
            end
            else if(sout1==0) begin
                temp_packet.port=1; //save data from sout1
                read_uart(temp_packet,sout1);
                very_important.output_packets.packet_0 = temp_packet.packet_0;
                very_important.output_packets.packet_1 = temp_packet.packet_1;
                very_important.output_packets.is_prog = temp_packet.is_prog;
                very_important.output_packets.port = temp_packet.port;
                output_monitor_h.write_to_monitor(very_important);
            end
            else begin
            end
        end
    end
endinterface : switch_bfm
    