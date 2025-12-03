class env extends uvm_env;
    `uvm_component_utils(env)

//------------------------------------------------------------------------------
// testbench elements
//------------------------------------------------------------------------------
    random_tpgen tpgen_h;
    driver driver_h;
    uvm_tlm_fifo #(packet_s) packet_f;

    coverage coverage_h;
    scoreboard scoreboard_h;
    input_monitor input_monitor_h;
    output_monitor output_monitor_h;
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction : new
    
//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        tpgen_h      = random_tpgen::type_id::create("tpgen_h",this);
        packet_f         = new("packet_f", this);
        coverage_h   = coverage::type_id::create ("coverage_h",this);
        driver_h          = driver::type_id::create("drive_h",this);
        scoreboard_h = scoreboard::type_id::create("scoreboard_h",this);
        input_monitor_h = input_monitor::type_id::create("input_monitor_h",this);
        output_monitor_h = output_monitor::type_id::create("output_monitor_h",this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// connect phase
//------------------------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        driver_h.packet_port.connect(packet_f.get_export);
        tpgen_h.packet_port.connect(packet_f.put_export);

        input_monitor_h.ap.connect(coverage_h.analysis_export);
        input_monitor_h.ap.connect(scoreboard_h.in_packets.analysis_export);
        output_monitor_h.ap.connect(scoreboard_h.analysis_export);
    endfunction : connect_phase

//------------------------------------------------------------------------------
// end-of-elaboration phase
//------------------------------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        // display created tpgen type
        $write("*** Created tpgen type: %s ***", tpgen_h.get_type_name());
        $write("\n");

    endfunction : end_of_elaboration_phase

endclass


