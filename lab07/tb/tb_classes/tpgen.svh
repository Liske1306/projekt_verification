class tpgen extends uvm_component;
    `uvm_component_utils(tpgen)

    uvm_put_port #(input_transaction) packet_port;

    //------------------------------------------------------------------------------
    // function prototypes
    //------------------------------------------------------------------------------
    /*pure virtual protected function bit [0:10] generate_uart_packet(
        input  bit         err_start,
        input  bit         err_parity,
        input  bit         err_stop
    );
    pure virtual protected function byte get_data();
    pure virtual protected task send_packets();*/

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

        input_transaction packet;

        phase.raise_objection(this);
        packet = new("packet");
        packet.is_rst = 1;
        packet.is_prog = 1;
        packet.packet_0 = 11'b01111001101; //dodanie adresu port 1(sprawdzenie czy podczas prog nie wypisuje)
        packet.packet_1 = 11'b01000000011;
        packet_port.put(packet);

        packet = input_transaction::type_id::create("packet");

        repeat (10) begin
            packet = new("packet");
            packet.is_rst=1;
            packet.is_prog=0;
            packet.packet_0 = 11'b01111001101; 
            packet.packet_1 = 11'b00000000001;
            packet_port.put(packet);
        end
        packet = new("packet");
        packet.is_rst=1;
        packet.is_prog=0;
        packet.packet_0 = 11'b01111001101; 
        packet.packet_1 = 11'b00000000001;
        packet_port.put(packet);

        packet = new("packet");
        packet.is_rst=0;
        packet.is_prog=1;
        packet.packet_0 = 11'b01111001101; 
        packet.packet_1 = 11'b01111111101;
        packet_port.put(packet);

        packet = new("packet");
        packet.is_rst=0;
        packet.is_prog=0;
        packet.packet_0 = 11'b01111001101; 
        packet.packet_1 = 11'b01111111101;
        packet_port.put(packet);

        #9999999999999;
        phase.drop_objection(this);

    endtask : run_phase


endclass : tpgen
