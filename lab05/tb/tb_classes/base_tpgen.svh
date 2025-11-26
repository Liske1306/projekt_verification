virtual class base_tpgen extends uvm_component;

    // The macro is not there as we never instantiate/use the base_tpgen
    //    `uvm_component_utils(base_tpgen)

    protected virtual switch_bfm bfm;

    //------------------------------------------------------------------------------
    // constructor
    //------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //------------------------------------------------------------------------------
    // function prototypes
    //------------------------------------------------------------------------------
    pure virtual protected function bit [0:10] generate_uart_packet(
        input  bit         err_start,
        input  bit         err_parity,
        input  bit         err_stop
    );
    pure virtual protected function byte get_data();
    pure virtual protected task send_packets();

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
        integer i;
        integer report_queue_index[$];

        bfm.sin = 1;
        bfm.rst_n = 0;

        repeat(32)@(posedge bfm.clk);
        bfm.rst_n = 1;

        send_packets();
  
        bfm.rst_n = 0;
        bfm.packet_0 = 11'b01111111101; //prawidłowy przesył dana max
        bfm.packet_1 = 11'b01111111101;
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

        bfm.prog = 1;

        bfm.packet_0 = 11'b01111111101; //dodanie adresu max
        bfm.packet_1 = 11'b00000000001;
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

        repeat(50) repeat (16) @(posedge bfm.clk);


        phase.drop_objection(this);

    endtask : run_phase


endclass : base_tpgen
