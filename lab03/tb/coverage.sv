module coverage(switch_bfm bfm);
    import switch_tb_pkg::*;

    //------------------------
    //      Covergroup       |
    //------------------------
    
    covergroup cov_data @(posedge bfm.clk);
        coverpoint bfm.packet_0 {//max min values
            bins max0 = {11'b01111111101};
            bins min0 = {11'b00000000001};
        }
        coverpoint bfm.packet_1 {
            bins max1 = {11'b01111111101};
            bins min1 = {11'b00000000001};
        }
        coverpoint check_packet(bfm.packet_1) {//all error types
            bins packet_ok  = {0};
            bins start_bad  = {1};
            bins parity_bad = {2};
            bins stop_bad   = {3};
        }
        coverpoint bfm.sout1 {//output on both sout
            bins signal0  = {0};
            bins idle0  = {1};
        }
        coverpoint bfm.sout0 {
            bins signal0  = {0};
            bins idle0  = {1};
        }
        coverpoint bfm.sin {//input gets to sin
            bins signal0  = {0};
            bins idle0  = {1};
        }
        coverpoint bfm.prog {//prog is used and functional
            bins progr  = {0};
            bins funct  = {1};
        }
    endgroup

    cov_data cover_addr;
    initial begin
        cover_addr = new();
    end
endmodule