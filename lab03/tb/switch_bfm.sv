interface switch_bfm;
    import switch_tb_pkg::*;
    
    bit                  clk;
    bit                  rst_n;
    bit                  prog;
    bit                  sin;
    bit                  sout0;
    bit                  sout1;
    logic        [10:0]  packet_0;
    logic        [10:0]  packet_1;
    test_result_t        test_result = TEST_PASSED;
    
    modport tlm (import get_data, generate_uart_packet, send_uart);
        
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

    //---------------------------------
    // Random data generation functions
    
    function byte get_data();
    
        bit [1:0] zero_ones;
    
        zero_ones = 2'($random);
    
        if (zero_ones == 2'b00)
            return 8'h00;
        else if (zero_ones == 2'b11)
            return 8'hFF;
        else
            return 8'($random);
    endfunction : get_data
            
    //---------------------------------
    // Generate 11 bit UART packet
    function bit [0:10] generate_uart_packet(
        input  bit         err_start,       
        input  bit         err_parity,      
        input  bit         err_stop         
    );
        logic [7:0]data_byte;
        logic parity_bit;
        logic start_bit;
        logic stop_bit;
        logic [0:10] uart_packet;

        start_bit = 1'b0;
        stop_bit  = 1'b1;
        data_byte = get_data();
        parity_bit = ^data_byte;

        if (err_start)  begin
            start_bit  = ~start_bit;
            parity_bit  = ~parity_bit;
        end
        if (err_parity) parity_bit = ~parity_bit;
        if (err_stop)   stop_bit   = ~stop_bit;

        uart_packet = {start_bit, data_byte, parity_bit, stop_bit};

        return uart_packet;
    endfunction : generate_uart_packet
    
    //------------------------
    // Send UART packet (b1+b0)

    task send_uart(
        input logic [10:0] packet_0,
        input logic [10:0] packet_1
        ); 
        begin
            uart_packet_sent temp_packet_sent;
            address_port temp_addr_port;
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
    