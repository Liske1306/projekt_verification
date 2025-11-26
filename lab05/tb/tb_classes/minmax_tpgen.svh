class minmax_tpgen extends random_tpgen;
    `uvm_component_utils(minmax_tpgen)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    protected task send_packets();
        bfm.prog = 1;
        bfm.packet_0 = 11'b01111001101; //dodanie adresu port 1(sprawdzenie czy podczas prog nie wypisuje)
        bfm.packet_1 = 11'b01000000011;
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

        bfm.packet_0 = 11'b01111000001; //dodanie adresu port 0
        bfm.packet_1 = 11'b00000000001;
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

        bfm.packet_0 = 11'b00000000001; //dodanie adresu min
        bfm.packet_1 = 11'b00000000001;
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

        bfm.packet_0 = 11'b01111111101; //dodanie adresu max
        bfm.packet_1 = 11'b00000000001;
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

        bfm.prog = 0;
        
        bfm.packet_0 = 11'b01111111101; //prawidłowy przesył adrr max
        bfm.packet_1 = generate_uart_packet(0,0,0);
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

        bfm.packet_0 = 11'b00000000001; //prawidłowy przesył adrr min
        bfm.packet_1 = generate_uart_packet(0,0,0);
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

        bfm.packet_0 = 11'b01111111101; //prawidłowy przesył dana max
        bfm.packet_1 = 11'b01111111101;
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

        bfm.packet_0 = 11'b00000000001; //prawidłowy przesył dana min
        bfm.packet_1 = 11'b00000000001;
        bfm.send_uart(bfm.packet_0, bfm.packet_1);
    endtask
endclass : add_tpgen
