/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

 History:
 2021-10-05 RSz, AGH UST - test modified to send all the data on negedge clk
 and check the data on the correct clock edge (covergroup on posedge
 and scoreboard on negedge). Scoreboard and coverage removed.
 */
module top;

    //------------------------------------------------------------------------------
    // Type definitions
    //------------------------------------------------------------------------------
    
    typedef enum bit {
        TEST_PASSED,
        TEST_FAILED
    } test_result_t;
    
    typedef enum {
        COLOR_BOLD_BLACK_ON_GREEN,
        COLOR_BOLD_BLACK_ON_RED,
        COLOR_BOLD_BLACK_ON_YELLOW,
        COLOR_BOLD_BLUE_ON_WHITE,
        COLOR_BLUE_ON_WHITE,
        COLOR_DEFAULT
    } print_color_t;
    
    //------------------------------------------------------------------------------
    // Local variables
    //------------------------------------------------------------------------------
    bit                  clk;
    bit                  rst_n;
    bit                  prog;
    bit                  sin;
    bit                  sout0;
    bit                  sout1;
        
    test_result_t        test_result = TEST_PASSED;
    
    //------------------------------------------------------------------------------
    // DUT instantiation
    //------------------------------------------------------------------------------
    
    simple_switch_uart DUT (.clk, .rst_n, .prog, .sin, .sout0, .sout1);
    
    //------------------------------------------------------------------------------
    // Clock generator
    //------------------------------------------------------------------------------
    
    initial begin : clk_gen_blk
        clk = 0;
        forever begin : clk_frv_blk
            #10;
            clk = ~clk;
        end
    end
    
    // timestamp monitor
    initial begin
        longint clk_counter;
        clk_counter = 0;
        forever begin
            @(posedge clk) clk_counter++;
            if(clk_counter % 1000 == 0) begin
                $display("%0t Clock cycles elapsed: %0d", $time, clk_counter);
            end
        end
    end
    
    //------------------------------------------------------------------------------
    // Tester
    //------------------------------------------------------------------------------

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
    function bit [0:10] generate_uart_packet(
        input  bit         err_start,       // Inject error in start bit
        input  bit         err_parity,      // Inject error in parity bit
        input  bit         err_stop         // Inject error in stop bit
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
        parity_bit = ~parity_bit;

        if (err_start)  start_bit  = ~start_bit;
        if (err_parity) parity_bit = ~parity_bit;
        if (err_stop)   stop_bit   = ~stop_bit;

        uart_packet = {start_bit, data_byte, parity_bit, stop_bit};

        return uart_packet;
    endfunction : generate_uart_packet
    
    //------------------------
    //Send UART packet (b1+b0)

    task send_uart(
        input logic [10:0] packet_0,
        input logic [10:0] packet_1
        ); 
        begin
        $display("-------------Sending packet-------------");
        $display("packet 0= %011b, packet 1= %011b",packet_0, packet_1);
        foreach(packet_0[i]) begin
            sin = packet_0[i];
            $display("sin= %d, sout0= %0d, sout1= %0d",sin,sout0, sout1);
            repeat (16) @(posedge clk);
        end
        $display("------------End packet 0-------------");
        foreach(packet_1[i]) begin
            sin = packet_1[i];
            $display("sin= %d, sout0= %0d, sout1= %0d",sin,sout0, sout1);
            repeat (16) @(posedge clk);
        end
        $display("------------End packet 1-------------");
        end
    endtask

    //------------------------
    // Tester main
    
    initial begin : main
        logic [10:0] packet_0;
        logic [10:0] packet_1;
        
        $display("start");
        sin = 1;
        prog = 1;
        rst_n = 0;
        packet_0 = 11'b00000001101; //address = 3
        packet_1 = 11'b01000000101; //port = 1

        repeat(32)@(posedge clk);
        rst_n = 1;

        send_uart(packet_0, packet_1);//address to sout 1

        packet_0 = 11'b00000010011; //address = 4
        packet_1 = 11'b00000000001; //port = 0

        send_uart(packet_0, packet_1);//address to sout 0 

        prog = 0;

        packet_0 = 11'b00000001101; //address = 3
        packet_1 = 11'b00001010111; //data (port1)
        send_uart(packet_0, packet_1);

        packet_0 = 11'b00000010011; //address = 4
        packet_1 = 11'b00000000111; //data (port0)
        send_uart(packet_0, packet_1);

        repeat (100) begin 
            $display("sin= %d, sout0= %0d, sout1= %0d",sin,sout0, sout1);
            repeat (16) @(posedge clk);
        end
        $display("finish");
        $finish;
    end : main
    
    //------------------------------------------------------------------------------
    // reset task
    //------------------------------------------------------------------------------
    
    //------------------------------------------------------------------------------
    // calculate expected result
    //------------------------------------------------------------------------------
    
    //------------------------------------------------------------------------------
    // Temporary. The scoreboard will be later used for checking the data
    final begin : finish_of_the_test
        print_test_result(test_result);
    end
    
    //------------------------------------------------------------------------------
    // Other functions
    //------------------------------------------------------------------------------
    
    // used to modify the color of the text printed on the terminal
    function void set_print_color ( print_color_t c );
        string ctl;
        case(c)
            COLOR_BOLD_BLACK_ON_GREEN : ctl  = "\033\[1;30m\033\[102m";
            COLOR_BOLD_BLACK_ON_RED : ctl    = "\033\[1;30m\033\[101m";
            COLOR_BOLD_BLACK_ON_YELLOW : ctl = "\033\[1;30m\033\[103m";
            COLOR_BOLD_BLUE_ON_WHITE : ctl   = "\033\[1;34m\033\[107m";
            COLOR_BLUE_ON_WHITE : ctl        = "\033\[0;34m\033\[107m";
            COLOR_DEFAULT : ctl              = "\033\[0m\n";
            default : begin
                $error("set_print_color: bad argument");
                ctl                          = "";
            end
        endcase
        $write(ctl);
    endfunction
    
    function void print_test_result (test_result_t r);
        if(r == TEST_PASSED) begin
            set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
            $write ("-----------------------------------\n");
            $write ("----------- Test PASSED -----------\n");
            $write ("-----------------------------------");
            set_print_color(COLOR_DEFAULT);
            $write ("\n");
        end
        else begin
            set_print_color(COLOR_BOLD_BLACK_ON_RED);
            $write ("-----------------------------------\n");
            $write ("----------- Test FAILED -----------\n");
            $write ("-----------------------------------");
            set_print_color(COLOR_DEFAULT);
            $write ("\n");
        end
    endfunction
    
    
    endmodule : top
    