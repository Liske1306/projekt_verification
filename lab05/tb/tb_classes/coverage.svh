class coverage extends uvm_component;
    `uvm_component_utils(coverage)
    
    protected virtual switch_bfm   bfm;
    protected bit                  rst_n;
    protected bit                  prog;
    protected logic                sin;
    protected logic                sout0;
    protected logic                sout1;
    protected logic        [10:0]  packet_0;
    protected logic        [10:0]  packet_1;
    //------------------------
    //      Covergroup       |
    //------------------------
    
    covergroup cov_data @(posedge bfm.clk);
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
        coverpoint sout1 {//output on both sout
            bins signal0  = {0};
            bins idle0  = {1};
        }
        coverpoint sout0 {
            bins signal0  = {0};
            bins idle0  = {1};
        }
        coverpoint sin {//input gets to sin
            bins signal0  = {0};
            bins idle0  = {1};
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
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual switch_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        forever begin : sampling_block
            @(posedge bfm.clk);
            rst_n = bfm.rst_n;
            prog = bfm.prog;
            sin = bfm.sin;
            sout0 = bfm.sout0;
            sout1 = bfm.sout1;
            packet_0 = bfm.packet_0;
            packet_1 = bfm.packet_1;
        end : sampling_block
    endtask : run_phase

endclass