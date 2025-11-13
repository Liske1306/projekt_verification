class tpgen;

    protected virtual switch_bfm bfm;

    function new (virtual switch_bfm b);
        bfm = b;
    endfunction : new

    //---------------------------------
    // Random data generation functions
    
    protected function byte get_data();
    
        bit [1:0] zero_ones;
    
        zero_ones = 2'($random);
    
        if (zero_ones == 2'b00)
            return 8'h00;
        else if (zero_ones == 2'b11)
            return 8'hFF;
        else
            return 8'($random);
    endfunction : get_data
            
    //---------------------------------
    // Generate 11 bit UART packet
    protected function bit [0:10] generate_uart_packet(
        input  bit         err_start,       
        input  bit         err_parity,      
        input  bit         err_stop         
    );
        logic [7:0]data_byte;
        logic parity_bit;
        logic start_bit;
        logic stop_bit;
        logic [0:10] uart_packet;

        start_bit = 1'b0;
        stop_bit  = 1'b1;
        data_byte = get_data();
        parity_bit = ^data_byte;

        if (err_start)  begin
            start_bit  = ~start_bit;
            parity_bit  = ~parity_bit;
        end
        if (err_parity) parity_bit = ~parity_bit;
        if (err_stop)   stop_bit   = ~stop_bit;

        uart_packet = {start_bit, data_byte, parity_bit, stop_bit};

        return uart_packet;
    endfunction : generate_uart_packet

    //------------------------
    // Tester main
    
    task execute();
        integer i;
        integer report_queue_index[$];

        bfm.sin = 1;
        bfm.prog = 1;
        bfm.rst_n = 0;

        repeat(32)@(posedge bfm.clk);
        bfm.rst_n = 1;

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

        bfm.packet_0 = 11'b01111111101; //prawidłowy przesył port 0
        bfm.packet_1 = generate_uart_packet(0,0,0);
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

        bfm.packet_0 = 11'b01111001101; //prawidłowy przesył port 1
        bfm.packet_1 = generate_uart_packet(0,0,0);
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

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

        bfm.packet_0 = 11'b00111110101; //przesyl na nieistniejacy adres (nie obchodzi go adres)
        bfm.packet_1 = 11'b00000000001;
        bfm.send_uart(bfm.packet_0, bfm.packet_1);
        
        bfm.packet_0 = 11'b01111000001; //bledny bit startu(ciagly przesyl paczek err)
        repeat(50)begin
        bfm.packet_1 = generate_uart_packet(1,0,0);
        //bfm.send_uart(bfm.packet_0, bfm.packet_1);
        end

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

        bfm.packet_0 = 11'b01111000001; //bledny bit startu opoznienie
        repeat(50)begin
        repeat(352)@(posedge bfm.clk);
        bfm.packet_1 = generate_uart_packet(1,0,0);
        //bfm.send_uart(bfm.packet_0, bfm.packet_1);
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

        bfm.rst_n = 0;
        bfm.packet_0 = 11'b01111111101; //prawidłowy przesył dana max
        bfm.packet_1 = 11'b01111111101;
        bfm.send_uart(bfm.packet_0, bfm.packet_1);

        bfm.prog = 1;

        bfm.packet_0 = 11'b01111111101; //dodanie adresu max
        bfm.packet_1 = 11'b00000000001; 
        bfm.send_uart(bfm.packet_0, bfm.packet_1);
        
        repeat(50) repeat (16) @(posedge bfm.clk);

    endtask : execute
    
endclass