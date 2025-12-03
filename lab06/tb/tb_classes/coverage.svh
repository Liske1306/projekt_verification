class coverage extends uvm_subscriber #(uart_packet_sent);
    `uvm_component_utils(coverage)
    
    protected bit                  prog;
    protected logic        [10:0]  packet_0;
    protected logic        [10:0]  packet_1;
    //------------------------
    //      Covergroup       |
    //------------------------
    
    covergroup cov_data;
        coverpoint packet_0 {//max min values
            bins max0 = {11'b01111111101};
            bins min0 = {11'b00000000001};
        }
        coverpoint packet_1 {
            bins max1 = {11'b01111111101};
            bins min1 = {11'b00000000001};
        }
        coverpoint check_packet(packet_1) {//all error types
            bins packet_ok  = {0};
            bins start_bad  = {1};
            bins parity_bad = {2};
            bins stop_bad   = {3};
        }
        coverpoint prog {//prog is used and functional
            bins progr  = {0};
            bins funct  = {1};
        }
    endgroup

    //------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
        cov_data             = new();
    endfunction : new

//------------------------------------------------------------------------------
// subscriber write function
//------------------------------------------------------------------------------
    function void write(uart_packet_sent t);
        prog = t.is_prog;
        packet_0 = t.packet_0;
        packet_1 = t.packet_1;
        cov_data.sample();
    endfunction : write
endclass