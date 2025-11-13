class testbench;

    virtual switch_bfm bfm;

    tpgen tpgen_h;
    coverage coverage_h;
    scoreboard scoreboard_h;

    function new (virtual switch_bfm b);
        bfm          = b;
        tpgen_h      = new(bfm);
        coverage_h   = new(bfm);
        scoreboard_h = new(bfm);
    endfunction : new

    task execute();
        fork
            coverage_h.execute();
            scoreboard_h.execute();
        join_none
        tpgen_h.execute();
        scoreboard_h.print_result();
    endtask : execute

endclass : testbench


