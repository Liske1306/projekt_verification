class err_tpgen extends random_tpgen;
    `uvm_component_utils(err_tpgen)

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
        
        bfm.packet_0 = 11'b01111000001; //bledny bit parity(ciagly przesyl paczek err)
        repeat(500)begin
            bfm.packet_1 = generate_uart_packet(0,1,0);
            //$display("%11b",packet_1);
            bfm.send_uart(bfm.packet_0, bfm.packet_1);
        end

        bfm.packet_0 = 11'b01111000001; //bledny bit stopu(ciagly przesyl paczek err)
        repeat(500)begin
            bfm.packet_1 = generate_uart_packet(0,0,1);
            //$display("%11b",packet_1);
            bfm.send_uart(bfm.packet_0, bfm.packet_1);
        end

        bfm.packet_0 = 11'b01111000001; //bledny bit parity opoznienie
        repeat(50)begin
            repeat(352)@(posedge bfm.clk);
            bfm.packet_1 = generate_uart_packet(0,1,0);
        //bfm.send_uart(bfm.packet_0, bfm.packet_1);
        end

        bfm.packet_0 = 11'b01111000001; //bledny bit stopu opoznienie
        repeat(50)begin
            repeat(352)@(posedge bfm.clk);
            bfm.packet_1 = generate_uart_packet(0,0,1);
        //bfm.send_uart(bfm.packet_0, bfm.packet_1);
        end

    endtask
endclass : err_tpgen
