class env extends uvm_env;
    `uvm_component_utils(env)

//------------------------------------------------------------------------------
// testbench elements
//------------------------------------------------------------------------------
    random_tpgen tpgen_h;
    coverage coverage_h;
    scoreboard scoreboard_h;

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        tpgen_h      = random_tpgen::type_id::create("tpgen_h",this);
        coverage_h   = coverage::type_id::create ("coverage_h",this);
        scoreboard_h = scoreboard::type_id::create("scoreboard_h",this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// end-of-elaboration phase
//------------------------------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        // display created tpgen type
        $write("*** Created tpgen type: %s ***", tpgen_h.get_type_name());
        $write("\n");

    endfunction : end_of_elaboration_phase

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction : new

endclass


