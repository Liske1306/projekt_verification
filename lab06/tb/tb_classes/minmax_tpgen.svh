class minmax_tpgen extends random_tpgen;
    `uvm_component_utils(minmax_tpgen)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    protected task send_packets();
        packet_s packet;

        packet.is_rst = 1;
        packet.is_prog = 1;
        packet.packet_0 = 11'b01111001101; //dodanie adresu port 1(sprawdzenie czy podczas prog nie wypisuje)
        packet.packet_1 = 11'b01000000011;
        packet_port.put(packet);

        packet.packet_0 = 11'b01111000001; //dodanie adresu port 0
        packet.packet_1 = 11'b00000000001;
        packet_port.put(packet);

        packet.packet_0 = 11'b00000000001; //dodanie adresu min
        packet.packet_1 = 11'b00000000001;
        packet_port.put(packet);

        packet.packet_0 = 11'b01111111101; //dodanie adresu max
        packet.packet_1 = 11'b00000000001;
        packet_port.put(packet);

        packet.is_prog = 0;
        
        packet.packet_0 = 11'b01111111101; //prawidłowy przesył adrr max
        packet.packet_1 = generate_uart_packet(0,0,0);
        packet_port.put(packet);

        packet.packet_0 = 11'b00000000001; //prawidłowy przesył adrr min
        packet.packet_1 = generate_uart_packet(0,0,0);
        packet_port.put(packet);

        packet.packet_0 = 11'b01111111101; //prawidłowy przesył dana max
        packet.packet_1 = 11'b01111111101;
        packet_port.put(packet);

        packet.packet_0 = 11'b00000000001; //prawidłowy przesył dana min
        packet.packet_1 = 11'b00000000001;
        packet_port.put(packet);
    endtask
endclass : minmax_tpgen
