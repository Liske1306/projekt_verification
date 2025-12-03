virtual class base_tpgen extends uvm_component;

    // The macro is not there as we never instantiate/use the base_tpgen
    //    `uvm_component_utils(base_tpgen)

    uvm_put_port #(packet_s) packet_port;

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
    // constructor
    //------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //------------------------------------------------------------------------------
    // build phase
    //------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        packet_port = new("packet_port", this);
    endfunction : build_phase

    //------------------------------------------------------------------------------
    // run phase
    //------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);

        packet_s packet;

        phase.raise_objection(this);
        send_packets();

        packet.is_rst=0;
        packet.is_prog=1;
        packet.packet_0 = 11'b01111111101; //prawidłowy przesył dana max
        packet.packet_1 = 11'b01111111101;
        packet_port.put(packet);

        packet.is_rst=0;
        packet.is_prog=0;
        packet.packet_0 = 11'b01111111101; //prawidłowy przesył dana max
        packet.packet_1 = 11'b01111111101;
        packet_port.put(packet);

        #1000;
        phase.drop_objection(this);

    endtask : run_phase


endclass : base_tpgen
