package switch_tb_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    typedef struct packed {
        bit [10:0] packet_0;
        bit [10:0] packet_1;
        bit        is_prog;
        bit        is_rst;
    } packet_s;

    typedef struct {
        bit [10:0] packet_0;
        bit [10:0] packet_1;
        time       timestamp;
        logic      port;
        bit        is_prog;
    } uart_packet_sent;

    typedef struct {
        logic [10:0] address;
        logic        port;
    } address_port;

    function bit [1:0] check_packet(
        input bit [10:0] packet_test
    );
        if(packet_test[10]!=0)begin
            return 1;
        end
        if(packet_test[1]!=^packet_test[10:2])begin
            return 2;
        end
        if(packet_test[0]!=1)begin
            return 3;
        end
        return 0;
    endfunction

//------------------------------------------------------------------------------
// testbench classes
//------------------------------------------------------------------------------
    `include "coverage.svh"
    `include "input_monitor.svh"
    `include "output_monitor.svh"
    `include "scoreboard.svh"
    `include "base_tpgen.svh"
    `include "random_tpgen.svh"
    `include "minmax_tpgen.svh"
    `include "err_tpgen.svh"
    `include "driver.svh"
    `include "env.svh"
    
    //------------------------------------------------------------------------------
    // test classes
    //------------------------------------------------------------------------------
    `include "random_test.svh"
    `include "minmax_test.svh"
    `include "err_test.svh"
endpackage
